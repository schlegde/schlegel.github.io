---
layout: post
title: "Consumer Driven Contract Testing"
date:   2018-08-08
description: ""
category:
tags: []
---

At one point we all have used, or will have used, some REST API where we did not care about most of the response fields. We might care about the name or the repos of a [Github user](https://developer.github.com/v3/users/#get-a-single-user) but not about his email or followers. On the other side developers might be scared to remove fields from a response because they have no idea if anyone, and if then who, uses the field.

Maybe there were even APIs which, if we wanted to display relevant data to our users, we had to do three requests, which were all depending on the previous request. For example we might have to fetch a user by id, then all his friends, to then get the birthday of her friends.

There are some projects built right now with beautiful APIs, some might be using [HATEOAS](https://en.wikipedia.org/wiki/HATEOAS), just to have the frontend developers ask "Can't we just do everything with GET requests?".

One way to deal with the issues above is to employ a technique called [Consumer Driven Contract Testing](https://martinfowler.com/articles/consumerDrivenContracts.html). The consumers, e.g. the teams working on an iOS app or a React webapp, specify what data they required from the API. These requirements will be provided as a contract. Put into a sentence the contract might define the following

> If I, the consumer, call the api endpoint /users/{userId} with a specific userId then I expect the api to return the address of the user.

Another consumer might state

> If I, the consumer, call the api endpoint /users/{userId} with a specific userId then I expect the api to return the birthday of the user.

To allow the verification of these contracts the sentences above have to be put into code.

### An Example

The following example use [Spring Cloud Contract](https://cloud.spring.io/spring-cloud-contract/)

As displayed above, we have two consumers of the API. One consumer is interested in the `address` of a user. The other consumer is interested in the `birthday` of the user. Both consumers will write a contract each. They specify the attributes they care about and provide it to the producer to fulfill.

#### Contract 1: Provide the address of a user

{% highlight groovy %}
org.springframework.cloud.contract.spec.Contract.make {
    request {
        method GET()

        url("/users/1")
    }

    response {
        status 200
        body("""
            {
                "id": 1,
                "address": "Somestreet 123 in City"
            }
        """)
    }
}
{% endhighlight %}

#### Contract 2: Provide the birthday of a user

{% highlight groovy %}
org.springframework.cloud.contract.spec.Contract.make {
    request {
        method GET()

        url("/users/2")
    }

    response {
        status 200
        body("""
            {
                "id": 2,
                "birthday": "1995-08-15"
            }
        """)
    }
}
{% endhighlight %}

We explicitly went for two contracts to display the fact that lots of services have multiple consumers.

Of course these contracts are not just blindly accepted and fulfilled by the producers. A nice side effect of these contracts is to start a conversation between consumers and producers, which should result in a proper API that fits both side. The conversation often leads to a [Backend For Frontends](https://samnewman.io/patterns/architectural/bff/) Pattern.

The structure will look as follows

### Consumer side

The contracts will generate stub files for the consumers. These stub files could be plain JSON files can be interpreted by specific HTTP-servers to make sure if the HTTP-Server is called with specific values the response described in the contract is provided. Thus a consumer calling `/users/2` on the HTTP-Server will receive the `birthday` field and when calling `/users/1` will receive the `address` field. As a result its important the requests differ in the url or query parameters to differentiate their required response.

![Consumer side](https://www.dropbox.com/s/y3mreruu3258smc/consumer_side.svg?raw=1)

Now the consumer is able to write the HTTP clients and json parsers to work with the response provided with the stub.


### Provider side

![Provider side](https://www.dropbox.com/s/iu4zhcmaqatu7ww/provider_side.svg?raw=1)

With the tests the provider can make sure his API abides by the contract. Any breakage of API should lead to a failing test.

It's important the stubs the consumer is using does not get out of sync with the contract. This is often achieved by having the CDCT library download the newest stubs during a test run. Of course the contract should not change after the fact. That's where the consumer driven part shines. The provider should not change the contracts. But if he does having up to date stubs at least serves as an early warning.

Let's say the malicious provider removes fields from the response. Of course the generated tests will fail and he knows something went wrong. But as soon as he also removes the field from the contract there will be no more test verifying whether the value is present or not. The contract was broken. But if the consumer is always using the latest stub files he will notice the stubs suddenly lack a field he is expecting. Appropriate measures can then be taken, e.g. notifying the provider team about the issue at hand.

### Issues

Some users don't like how the tests ignore unknown fields. E.g. the API could return

{% highlight json %}
{
  "address": "Somestreet 123 in City",
  "birthday": "1995-08-15",
  "foo": "bar"
}
{% endhighlight %}

and the test would not care at all if the response contains `"foo":"bar"`, nor should it. The reason is [Postel's law](https://en.wikipedia.org/wiki/Robustness_principle), often stated as:

> Be conservative in what you send, be liberal in what you accept

[Martin Fowler states it](https://martinfowler.com/bliki/TolerantReader.html) as:

> My recommendation is to be as tolerant as possible when reading data from a service. If you're consuming an XML file, then only take the elements you need, ignore anything you don't.

These consumers would be considered __tolerant readers__ and support the evolution of services without breaking.

Additionally we should remember the contracts are not the schema of the API. We have better tools to achieve that. [Swagger](https://swagger.io/) comes to mind.

Another thing which leads to pain is asserting the explicit values when testing the parsers and HTTP-Clients.

The consumers should not have a test around which attempts the following

{% highlight java %}
assertThat(response.address).isEqualTo("Somestreet 123 in City");
{% endhighlight %}

The above would lead to a failing test if the provider would ever change the value to `Somestreet 123 in Town` although the contract was not broken. Thus having the following test instead would greatly improve the stability.

{% highlight java %}
assertThat(response.address).isNotBlank();
{% endhighlight %}

### Summary

In one of my projects were extensively using CDCT. We use it both to keep our backends and clients in sync and also to keep the interaction of the different backends (Messaging and REST) in sync. I would not even want to miss it outside of a microservices environment. One or more consumers of an API would already warrant the technique.

Not enough? We can also use CDCT to write [integration tests for third party API]({% post_url 2018-05-13-integration-tests-for-third-party-apis %})
