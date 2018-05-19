---
layout: post
title: "Integration Tests for Third Party APIs"
date:   2018-05-13 16:36:05
description: ""
category:
tags: []
---

Have you ever pondered how to write integration tests for third party API? The following post might show you a new approach. We will be using [Consumer Driven Contract Testing (CDCT)](https://martinfowler.com/articles/consumerDrivenContracts.html).

Let's start with what a _Third Party API_ is supposed to be. We regard it as API which is not under our control. We cannot change it ourselves and asking for a change might take weeks or months. Examples range from the [Google Maps APIs](https://developers.google.com/maps) to some Legacy CRM system internal to our company.

Until the last year I have experienced three ways of dealing with these APIs from a testing perspective.

1. Not testing the integration at all
2. Hitting the live API
3. Check in the API responses (e.g. `.json` files) into source control

The first one is by far the easiest. We make sure the application still works by manually checking if the application does what its supposed to do and whether the correct values from the APIs are used.

With the second approach we make sure the API is properly integrated without the need to manually checking it. The downside is that these APIs might be slow to respond, leading to slow tests and tests which will fail if our CI tool loses the network connection. One might also run into rate limiting issues when the API is called too often in a short amount of time. We might even incur a cost for every request since not every API is free of charge.

The third approach is the one I usually encounter. With it we are neither subject of additional costs per request, slow tests or rate limiting issues. The real API is only ever hit once during the creation of the initial `.json` file. There are even tools which help us with the workflow such as [Ruby VCR](https://github.com/vcr/vcr).

Still, one issue arises. We would not notice right away if there is a mismatch between the response in the `.json` file and the actual response. Aside from sloppiness and not checking in the correct response, e.g. with missing structure, we would also not notice directly whether the API producer breaks the API by removing fields. The latter might be improbable when working with Google APIs but is certainly possible with company internal systems or the API of smaller vendors.

To mitigate the issues above a [colleague](https://twitter.com/maverick_1601) introduced the idea of using [Consumer Driven Contract Testing (CDCT)](https://martinfowler.com/articles/consumerDrivenContracts.html) for third party API. Since we're already using it for API we do have control over the tooling was already in place and the developers were versed in its usage.

CDCT is often called _TDD for microservices_ and used as such. The API consumers (e.g. an app or another microservice) writes contracts on how they require the API to behave and thus which fields of a response is used.

One consumer might be interested in the age field of the user, another might only care about the address.

On the provider side (a service) there will be a test which makes sure the contract is never violated. Thus if the provider removes a field from a response, which is not mentioned in any contract, all tests will still pass. The field was save to be removed. No consumer was using or expecting it. Thus for the example above one would not be able to remove the age or the address. Though removing the phone-number would be possible.

Of course we cannot give these contracts to the Google Maps API or to our legacy CRM system. These providers presumably neither care nor have the tooling in place to support CDCT. Thus on first glance using CDCT here seems odd. What we can do is create another service which acts as a replacement for the actual service during testing. The service will hold the contracts defining the required fields from the actual API. We call these services `proxies`. They never proxy requests but act as an intermediate between the API and the implementation during automated testing. The proxy project will have two jobs.

1. Make sure the API reponds as expected (Similar to using the real API during tests)
2. Provide stubs to consumers (Similar to checking in the response files)

Say we want to display how long it takes to drive from Stuttgart to Berlin. With the [Google Distance Matrix API](https://developers.google.com/maps/documentation/distance-matrix/start) we can get the following result. Here were using [HTTPie](https://httpie.org/).

{% highlight bash %}
http https://maps.googleapis.com/maps/api/distancematrix/json \
  origins==Berlin destinations==Stuttgart
{% endhighlight %}

And our result

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

It takes 6 hours and 18 minutes to drive from Berlin to Stuttgart.

At first glance the only piece of interest to us is the value `22651`. It is the amount of seconds it takes. Our consumers, e.g. an Android App, will decide how they want to format the value for the user.

We should make sure the `value` field is included in the response. Of course the documentation says it's included but we want to be extra careful. Using a [Groovy](http://groovy-lang.org/) DSL of [Spring Cloud Contract](https://github.com/spring-cloud/spring-cloud-contract) we can define the following contract.

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

It only contains the parts of the response we care about and which request would create the expected response. As a result the following test, asserting on the relevant fields, will be generated automatically.

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

If we provide the specified parameters in the request (`when:`), we expect the specified response (`then:`).

The DSL in the assertions is [JSON Assert](https://github.com/marcingrzejszczak/jsonassert), a fluent interface for [JsonPath](https://github.com/json-path/JsonPath). A side-effect is how we have now documented in code which fields we use. Maybe later during development we find a cheaper or faster API filling our requirement to have these durations calculated. We would only have to compare if they offer the same functionality we already require.

The generated contract tests pass without us writing any implementation code. Google already did all the work for us. We're done with the first step. Verifying the API works as expected.

Aside from the generated tests, which some might regard as useless in as _"Why would you want to test API you dont own?"_, we get some stubs. These stubs, which are mostly the response with some metadata as json file, can be used by our consumers to develop against. Its using [WireMock](http://wiremock.org/), a HTTP mock service, which returns the response defined in the contract when hit with the request defined in the contract. After all it was one of our initial goals to not permanentely call the real API and to have stubs which respond as the real API does.

These stubs are made available to other projects via the local `.m2` repository, a git repository or from our nexus or artifactory instance. An example using the local `.m2` repository can be found in the sources at the end.

In our consumer project we will need a `Client` to make the appropriate HTTP calls to get our desired duration. Using the stubs we can test drive its functionality.

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

Pretty straight forward. With the actual implementation, using [Feign](https://github.com/OpenFeign/feign), we should be able to make the test pass. (JsonPath is used for brevity)

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

To tell the test to hit the stub instead of the real API we need a service mapping configured below. In production you will want to point `google-distance-service` to `https://maps.googleapis.com`.

{% highlight java %}
stubrunner:
    ids: 'co.hodler:scdcproxy:+:stubs'
    stubsMode: LOCAL
    ids-to-service-ids:
        scdcproxy: google-distance-service
{% endhighlight %}

Our tests are passing. Nice. Let's ship it. We schedule a build to run the tests of the proxy project in an interval of our liking. For example once a day. The tests for the consumer projects can be run as often as we like. They never call the real API.

Are we done?

Not really. All seems fine until a road gets blocked and suddenly the duration takes one second more and we receive `22652` instead of `22651`. Subsequently leading to a failing test. Instead of just changing the value to `22652` and waiting for it to change again on a future date we should improve the resilience of the test.

The updated syntax of the value part would be

{% highlight groovy %}
value: $(stub(22651), test(regex('\\d+')))
{% endhighlight %}

Thus our `stub` (WireMock) will always provide the value `22651` to a consumer. The actual tests (the assertions) against the real API will only require the API to respond with at least one digit. That's what the `regex('\\d+')` is for. Thus our generated assertion will change to

{% highlight java %}
assertThatJson(parsedJson).array("['rows']")
    .array("['elements']").field("['duration']")
    .field("['value']").matches("\\d+");
{% endhighlight %}

The real API might return `12345` and the test would not care. Nor should it. Subsequently the test on the consumer side, which is expecting `22651` would not break.

Seems were done...

Not really, try to create the following request

{% highlight bash %}
http https://maps.googleapis.com/maps/api/distancematrix/json \
  origins==Stuttgart destinations=="Gotham City"
{% endhighlight %}

The API does not always return the duration. Definitely not when using a fictional city. We could, and should, create a second contract covering the error case and make sure our `Client` can deal with the error. Currently it can't. It would run straight into `NullPointerException`. Having contracts, and thus stubs, for these edge cases is a great way to harden the `Client` to deal with more than the happy path.

For the examples above everything looks great. Until we get to a requirement of preparing the API to respond with something specific. Say to fetch something via `GET` request we might need to first `POST` something. We also did not take into account adding a personal API key to the request. A way to address these issues will be part of a future post.

To summarize, using the above technique, we made sure

* The API behaves as we expect it to
* Aside from the proxy project, our tests do not call the real API
* We make sure there is no mismatch between the response we expect and the actual response
* We have documented which fields of an API we use

Hopefully this might be of use to others too. It surely is for us. We use the approach for every integrated third party API.

_The code for the [proxy project](https://github.com/axelhodler/scdcproxy) and the [consumer project](https://github.com/axelhodler/scdcconsumer) can be found on GitHub._
