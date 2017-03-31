---
layout: post
title: "Connect to Ethereum Smart Contracts in Java"
date:   2017-03-31 23:41:33
description: ""
category:
tags: []
---

Since quite a lot of business applications are written in Java, or make use of the [JVM](https://en.wikipedia.org/wiki/Java_virtual_machine) for that matter, I believe a primer on how to interface with an [Ethereum](https://www.ethereum.org/) [Smart Contract](https://en.wikipedia.org/wiki/Smart_contract) in Java will prove helpful to the reader.

This post requires knowledge of what a Smart Contract is and how to deploy one.

# Basics

To learn why we will probably use a library for interfacing with the Smart Contract a basic understanding of the usage of [JSON-RPC](https://github.com/ethereum/wiki/wiki/JSON-RPC) in Ethereum is necessary.

Let's unveil the supposed magic behind what almost all Ethereum libraries do to interact with the blockchain. Suppose we need to know the `gasLimit` (maximum amount of computational effort the transactions in a block are allowed to have) of the lastest block. Using [curl](https://curl.haxx.se/) and piping its result to a json parser such as [jq](https://stedolan.github.io/jq/) would, considering we run an ethereum node on localhost port 8545, look as follows

{% highlight bash %}
curl --silent -X POST -H "Content-Type: application/json"\
  --data '{"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["latest", true],"id":1}' localhost:8545 | jq .result.gasLimit
{% endhighlight %}

The above will yield `"0x4c4b3c"`, which is [hex-encoded](https://en.wikipedia.org/wiki/Hexadecimal). Since we probably want to read it as a decimal we can add another pipe and the final command becomes

{% highlight bash %}
curl --silent -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["latest", true],"id":1}' localhost:8545\
 | jq .result.gasLimit\
 | xargs printf '%d\n'
{% endhighlight %}

Leading to the readable result of `4999996`.

These steps involved are a good showcase on why to introduce an abstraction. Almost all libraries will provide convenient interfaces for these RPC calls.

Using the library [web3j](https://web3j.io) the command above will translate to

{% highlight java %}
web3j.ethGetBlockByNumber(DefaultBlockParameter.valueOf("latest"),
  true).send().getBlock().getGasLimit();
{% endhighlight %}

Still a lot of steps, and from a software-engineering perspective a violation of the [Law of demeter](https://en.wikipedia.org/wiki/Law_of_Demeter), yet less error prone and more convenient. Additionally, if our implementation depends on the funtionality above we will most likely create an abstraction such as `ethereumGateway.currentGasLimit()` anyway.

# Using web3j

Let's take web3j for a spin to interact with a simple record keeping contract. What the contract does is keep track of some kind of `Deliverable`, which could be a shipping container. It makes use of access controls to only allow the owner of the contract to modify its state. We achieve this with the `onlyByOwner` _function modifier_. The owner can `store` a new Deliverable and also change its status to `delivered`. Using the shipping container example this means the container has reached is destination. Querying the contract for the status of a `Deliverable` is possible by anyone using the `statusFor` function. If the `status` of a `Deliverable` is _1_ we can consider it delivered.

{% highlight javascript %}
contract Deliverables {
  address public owner;
  mapping (address => Deliverable) deliverables;

  struct Deliverable {
    address id;
    uint status;
  }

  modifier onlyByOwner() {
    if (msg.sender != owner) throw;
    _;
  }

  function Deliverables() {
    owner = msg.sender;
  }

  function store(address id) onlyByOwner {
    if (msg.sender != owner) throw;
    deliverables[id] = Deliverable(id, 0);
  }

  function statusFor(address id) constant returns(uint status){
    return deliverables[id].status;
  }

  function delivered(address id) onlyByOwner {
    if (msg.sender != owner) throw;
    deliverables[id].status = 1;
  }
}
{% endhighlight %}

Using the [web3j Command Line Tools](https://docs.web3j.io/command_line.html) we need to provide the hex-encoded binary and the application binary interface (ABI) files, an output folder and the package name.

{% highlight bash %}
web3j solidity generate compiled_contract/Deliverables.sol:Deliverables.bin compiled_contract/Deliverables.sol:Deliverables.abi -o src/main/java -p com.yopiter
{% endhighlight %}

It will create a `.java` file with the following contents. Some parts are left for the sake of brevity.

{% highlight java %}
public final class Deliverables extends Contract {
  // [...]
  Future<TransactionReceipt> store(Address id) {
    Function function = new Function("store", Arrays.<Type>asList(id), Collections.<TypeReference<?>>emptyList());
    return executeTransactionAsync(function);
  }

  public Future<TransactionReceipt> delivered(Address id) {
    Function function = new Function("delivered", Arrays.<Type>asList(id), Collections.<TypeReference<?>>emptyList());
    return executeTransactionAsync(function);
  }

  public Future<Uint256> statusFor(Address id) {
    Function function = new Function("statusFor",
                Arrays.<Type>asList(id),
                Arrays.<TypeReference<?>>asList(
      new TypeReference<Uint256>() {}));
    return executeCallSingleValueReturnAsync(function);
  }
  // [...]
}
{% endhighlight %}

We spot two methods to write to the contract, `store` and `delivered`, as in they return a `TransactionReceipt`. There is one method to query the contract for the status of a `Deliverable` via `statusFor`, which does return the queried value without the need for a transaction. It even uses the proper type `Uint256`. Every lover of type systems will feel right at home.

A sample interaction with the contract can be shown as an integration test

{% highlight java %}
@Test
public void deliverables_can_be_delivered() throws Exception {
  Deliverables deliverables = Deliverables.load(address, web3j,
    credentials, gasPrice, gasLimit);
  String hash = web3j.web3Sha3("CONTENTS").send().getResult();
  Address deliverable = new Address(hash);
  deliverables.store(deliverable).get();

  deliverables.delivered(deliverable).get();

  BigInteger result = deliverables.statusFor(deliverable).get()
    .getValue();
  assertThat(result, is(BigInteger.valueOf(1)));
}
{% endhighlight %}

Let's disect the code

{% highlight java %}
Deliverables.load(address, web3j, credentials, gasPrice, gasLimit);
{% endhighlight %}

We load the contract by providing its `address` an instance of `web3j`, the `credentials` (an unlocked wallet file), the `gasPrice` and `gasLimit`. Be aware that `credentials`, `gasPrice` or `gasLimit` would not really be necessary if we only intented to read from the contract. For example when using the `statusFor` function. Query operations on a contract are free in as they do not need a transaction and thus have no gas cost.

{% highlight java %}
web3j.web3Sha3("CONTENTS").send().getResult();
{% endhighlight %}

We create a hash of something unique, in our example it could be the shipping receipt, using [SHA-3](https://en.wikipedia.org/wiki/SHA-3).

Keep in mind we probably do not want to store full documents on the blockchain because we would need pay for every byte in a transaction. Using hashes is a way to keep the transactions small and cheap.

{% highlight java %}
deliverables.store(deliverable).get();
{% endhighlight %}

Next up we create the transaction to store the `Deliverable` on the blockchain and wait for the computation to complete.

{% highlight java %}
deliverables.delivered(deliverable).get();
{% endhighlight %}

Almost done we change the status of the `Deliverable` to delivered and, again, wait for the computation to complete.

{% highlight java %}
BigInteger result = deliverables.statusFor(deliverable).get()
  .getValue();
assertThat(result, is(BigInteger.valueOf(1)));
{% endhighlight %}

Finally we query the contract for the state and verify our `Deliverable` has been delivered.

# Conclusion

Having had a lot more experience with [web3.js](https://github.com/ethereum/web3.js) the _original_ library in Javascript it sometimes feels more tedious to work with it's sister library in Java.

As an example, if we want to use our account in web3.js we would write

{% highlight javascript %}
web3.personal.unlockAccount("someAddress", "somePassword")
{% endhighlight %}

In web3j we would have to read our wallet file and pass the `Credentials` instance around

{% highlight java %}
Credentials c = WalletUtils.loadCredentials("somePassword", "wallets/UTC-2017-03-31T09-19-59.503000000Z--6dc71522dfff6e05c450abe2a68e11392e31551d.json");
{% endhighlight %}

Regardless, in the end it boils down to personal taste. Of course web3.js is older, more mature and has more users than web3j, thus in the future web3j will improve too in every aspect.

As a sidenote, when thinking about the future of our application we should create an abstraction for any library or API we use. It will allow us to switch out the underlying implementation, without touching the modules containing the business logic, should we ever find a better way or library to interact with a smart contract. Furthermore it will enable us to use a somewhat different implementation of Smart Contracts such as the possible competitor on the Bitcoin blockchain [Rootstock](http://www.rsk.co/).
