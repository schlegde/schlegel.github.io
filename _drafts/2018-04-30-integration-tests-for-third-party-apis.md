---
layout: post
title: "Integration Tests for Third Party APIs"
date:   2018-04-29 16:36:05
description: ""
category:
tags: []
---

Have you ever pondered how to write integration tests for third party API? The following post might show you a new approach. We will be using [Consumer Driven Contract Testing (CDCT)](https://martinfowler.com/articles/consumerDrivenContracts.html).

Let's start with what a Third Party API is supposed to be. I regard it as API which is not under your control, in as you cannot change it. Examples range from the [Google Maps APIs](https://developers.google.com/maps) to some Legacy CRM system of your company.

Until a while ago I knew of three ways to deal with these APIs from a testing perspective.

1. Not testing the integration at all
2. Hitting the live API during your tests
3. Check in the API responses, e.g. `.json` files and hit these during you tests

The first one is the easiest. You make sure the application still works by manually checking if the application does what its supposed to do and whether the correct values from the APIs are used.

With the second approach you definitely make sure the API is properly integrated. The downside is that these APIs might be slow to respond, leading to slow tests and test which would fail if your CI tool lost the network connection. One might also run into rate limiting issues when the third party API is called too often and repeatedly in a short amount of time. You might even incur a cost for every request.

The third approach is the one I see most often. With it you are neither subject of additional costs per request, slow tests or rate limiting issues since the real API is only ever hit once during the creation of the initial `.json` file. There are even tools which help you with these such as [Ruby VCR](https://github.com/vcr/vcr).

An issue that arises is how you would not notice right away if there is a mismatch between the response in the `.json` file and the actual response. Aside from sloppyness and not checking in the correct response, e.g. with missing structure you would also not notice directly whether the API producer breaks the API by removing fields. The latter one might be improbable when working with Google APIs but are certainly possible with company internal systems or the API of smaller vendors.

To mitigate the issues above we started using [Consumer Driven Contract Testing (CDCT)](https://martinfowler.com/articles/consumerDrivenContracts.html). Often called _TDD for microservices_. The API consumers (e.g. an app or another microservice) writes a contracts on how he requires the API to behave and thus which fields of a response he uses. On the provider side (a service) there will be a test which makes sure the contract is never violated. Thus if the provider removes a field from a response, which is not mentioned in any contract, all tests will still pass. The field was save to be removed. No consumer was using or expecting it.

Of course we cannot give these contracts to a Google Maps API or to our legacy CRM system. They persumably neither care nor have the tooling in place to support CDCT. What we can do is create another service which acts as a replacement for the actual service. This service will hold the contracts defining the required fields from the actual API.

Let's look at an example.

Say we want to display how long it takes to drive from Stuttgart to Berlin. With the [Google Distance Matrix API](https://developers.google.com/maps/documentation/distance-matrix/start) we can get the following result via [HTTPie](https://httpie.org/)

{% highlight bash %}
http https://maps.googleapis.com/maps/api/distancematrix/json \
  origins==Berlin destinations==Stuttgart key==${YOUR_API_KEY}
{% endhighlight %}

{% highlight java %}
{
   "destination_addresses" : [ "Berlin, Germany" ],
   "origin_addresses" : [ "Stuttgart, Germany" ],
   "rows" : [
      {
         "elements" : [
            {
               "distance" : {
                  "text" : "636 km",
                  "value" : 635736
               },
               "duration" : {
                  "text" : "6 hours 18 mins",
                  "value" : 22651
               },
               "status" : "OK"
            }
         ]
      }
   ],
   "status" : "OK"
}
{% endhighlight %}

On first glance the only thing of interest to us is the value `22651`, which is the amount of seconds it takes. Our consumers, e.g. an Android App, will decide how they want to format the value.

Using a [Groovy](http://groovy-lang.org/) DSL we can define the following contract. It only contains the parts of the response we care about and which request would create the expected response.

{% highlight groovy %}
org.springframework.cloud.contract.spec.Contract.make {
    request {
        method GET()

        url("/maps/api/distancematrix/json") {
            queryParameters {
                parameter 'origins': 'Berlin'
                parameter 'destinations': 'Stuttgart'
            }
        }
    }

    response {
        status 200
        body([
            rows  : [[
                         elements: [[
                                        duration: [
                                            value: 22651
                                        ]
                                    ]]
                     ]],
        ])
    }
}
{% endhighlight %}

As a result the following test, asserting on the fields we care about, will be generated automatically.

{% highlight java %}
@Test
public void validate_shouldProvideDistanceBetweenTwoCities() {
    // when:
        Response response = webTarget
                .path("/maps/api/distancematrix/json")
                .queryParam("origins", "Berlin")
                .queryParam("destinations", "Stuttgart")
                .request()
                .method("GET");

        String responseAsString = response.readEntity(String.class);

    // then:
        assertThat(response.getStatus()).isEqualTo(200);
    // and:
        DocumentContext parsedJson = JsonPath.parse(responseAsString);
        assertThatJson(parsedJson).array("['rows']")
            .array("['elements']").field("['duration']")
            .field("['value']").isEqualTo(22651);
}
{% endhighlight %}

The DSL in the assertions is [JSON Assert](https://github.com/marcingrzejszczak/jsonassert), a fluent interface for [JsonPath](https://github.com/json-path/JsonPath).

Fine, but our API key is missing. We definitely do not want to hardcode it into our contract or duplicate it for every API call towards Google.

In our base class we can add an interceptor, which is going to add the API key to every request.

{% highlight java %}
@RunWith(SpringRunner.class)
@SpringBootTest(classes = ScdcproxyApplication.class)
public abstract class GoogleMapsBase {

    @Value("${google.api.key}")
    private String apiKey;

    protected WebTarget webTarget;

    @Before
    public void init_http_client() {
        Client client = ClientBuilder.newClient();

        ClientRequestFilter requestFilter = rc -> {
            String keyedUri = String.format("%s&key=%s",
                rc.getUri().toString(), apiKey);
            rc.setUri(URI.create(keyedUri));
        };
        client.register(requestFilter);

        webTarget = client.target("https://maps.googleapis.com");
    }
}
{% endhighlight %}

Running the generated contract tests would be successful.

Aside from the generated tests we will also get some stubs which can be used in other projects to develop against. After all it was one of our initial goals to not permanently call the real API. These stubs can be generated using the gradle task `generateClientStubs`. If we look into the `build/stubs` folder we can find them.

One easy way to make them available to other projects would be via the local `.m2` repository. In the real world you would want to look into better solutions, like getting the stubs from a git repository or from nexus or artifactory.

In another project, using the stubs, we can write a test for the `Client` we want to build.

{% highlight java %}
@SpringBootTest
@RunWith(SpringRunner.class)
@AutoConfigureStubRunner
public class GoogleDistanceMatrixClientTest {

  @Autowired
  GoogleDistanceMatrixClient subject;

  @Test
  public void can_get_duration_between_two_cities() {
    Integer duration = subject.getDrivingDurationBetween("Berlin",
      "Stuttgart");

    assertThat(duration).isEqualTo(22651);
  }
}
{% endhighlight %}

And the actual implementation to have a passing test (JsonPath is used for brevity)

{% highlight java %}
@FeignClient(value = "google-distance-service")
public interface GoogleDistanceMatrixClient {

  @GetMapping("/maps/api/distancematrix/json")
  String getDistance(@RequestParam("origins") String origin,
             @RequestParam("destinations") String destination);

  default Integer getDrivingDurationBetween(String origin,
      String destination) {
    return JsonPath.parse(this.getDistance(origin, destination))
      .read("$.rows[0].elements[0].duration.value", Integer.class);
  }
}
{% endhighlight %}

To get it to pass we need a service mapping to access the stub instead of the real API.

{% highlight java %}
stubrunner:
    ids: 'co.hodler:scdcproxy:+:stubs'
    stubsMode: LOCAL
    ids-to-service-ids:
        scdcproxy: google-distance-service
{% endhighlight %}

Our tests are passing. Ship it. Schedule a build to run these tests of the proxy project in an interval of your liking. For example once a day. The tests for the consumer projects can be ran as often as you like. They never call the real API.

Are we done?

All seems fine until a road gets blocked and suddenly the duration takes one second more and we receive `22652` instead of the expected `22651`. Subsequently leading to a failing test. Instead of just changing the value to `22652` and waiting for it to change again on a future date we should improve the resilience.

The updated syntax of the value part would be

{% highlight groovy %}
value: $(stub(22651), test(regex('\\d+')))
{% endhighlight %}

Thus our `stub` will always provide the value `22651` to a consumer. The actual tests against the real API will only require the API to respond with at least one digit. That's what the `regex('\\d+')` is for. Thus our generated assertion will change to

{% highlight java %}
assertThatJson(parsedJson).array("['rows']")
    .array("['elements']").field("['duration']")
    .field("['value']").matches("\\d+");
{% endhighlight %}

The code for the [proxy project](https://github.com/axelhodler/scdcproxy) and the [consumer project](https://github.com/axelhodler/scdcconsumer) can be found on GitHub.

All the above seems fine and dandy for now. Until we get to a requirement of preparing the API to respond with something specific. As an example to fetch something via `GET` request we might need to first `POST` something. A way to achieve the latter will be part of a future blogpost.



