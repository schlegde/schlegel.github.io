---
layout: post
title: "Testing Asynchronous Code in Angular"
date:   2017-01-06 12:00:42
description: ""
category:
tags: []
---

If you have ever wondered how to test promises in [Angular](https://angular.io/) this post is for you.

Assume we have a function which in turn invokes two other functions. Here `submitReport` will invoke two services. Our `report` will be persisted via `reportsGateway` and, if successful, the `router` will navigate the user to a list of reports.

{% highlight javascript %}
submitReport(report: string) {
  return this.reportsGateway.saveReport(report).then(() => {
    return this.router.navigate(['reports']);
  });
};
{% endhighlight %}

A developer not used to testing asynchronous code might write a unit test as follows

{% highlight javascript %}
it('navigates to reports after submitting a report', () => {
  spyOn(reportsGateway, 'saveReport')
    .and.returnValue(Promise.resolve());
  spyOn(router, 'navigate');

  component.submitReport('a report');

  expect(reportsGateway.saveReport).toHaveBeenCalledWith('a report');
  expect(router.navigate).toHaveBeenCalledWith(['reports']);
});
{% endhighlight %}

Running the test leads to

{% highlight bash %}
Expected spy navigate to have been called with [ [ 'reports' ] ] but
it was never called.
{% endhighlight %}

Why?

We can add a log statement into the anonymous `then` function and another one above our assertions. When running the tests we witness

{% highlight bash %}
LOG: 'Start assertions'
LOG: 'Promise resolved'
{% endhighlight %}

We have a timing issue. The assertion happens before the promise is resolved.

The quick and dirty solution is to add a timeout to the test after calling `submitReport`. It gives the promise enough time to resolve before checking the assertions.

{% highlight javascript %}
setTimeout(() => {
  expect(reportsGateway.saveReport)
    .toHaveBeenCalledWith('a report');
  expect(router.navigate).toHaveBeenCalledWith(['reports']);
}, 10);
{% endhighlight %}

Run the test and its passing. Sweet. Let's continue with the next feature...

Wait

Change the assertion on the `router` to state the opposite. Look at the added `not`

{% highlight javascript %}
expect(router.navigate).not.toHaveBeenCalledWith(['reports']);
{% endhighlight %}

Run it. The tests are still passing. How?

Because our test finishes without ever running the anonymous function in `setTimeout`. Thus the test has __0__ assertions.

We can fix it by telling the test case to wait. [Jasmine](https://jasmine.github.io/) offers [Asynchronous Support](https://jasmine.github.io/edge/introduction#section-Asynchronous_Support) via `done`. A test will not complete until `done` is called.

{% highlight javascript %}
it('navigates to reports after submitting a report', (done) => {
  // [...]
  setTimeout(() => {
    expect(reportsGateway.saveReport)
      .toHaveBeenCalledWith('a report');
    expect(router.navigate).toHaveBeenCalledWith(['reports']);
    done();
  }, 10);
});
{% endhighlight %}

Our test is back to green and fails as soon as we try to swap `toHaveBeenCalledWith(['reports'])` with `not.toHaveBeenCalledWith(['reports'])`.

Sadly, by going for the timeout solution, we have made our test unnecessarily slow. The test will wait these 10ms even if less would be fine too.

We can give the test exactly the amount it needs by using the Promise already returned by `submitReport`

{% highlight javascript %}
component.submitReport('a report').then(() => {
  expect(reportsGateway.saveReport).toHaveBeenCalledWith('a report');
  expect(router.navigate).toHaveBeenCalledWith(['reports']);
  done();
});
{% endhighlight %}

One issue I have with the above is the fact that `submitReport` has to return a `Promise` for it to work. What if we do not care about the return value? Additionally it intermingles the _Act_ and _Assert_ part in [Arrange Act Assert](http://wiki.c2.com/?ArrangeActAssert) and adds another level of indentation which decreases the readability.

Thankfully Angular offers [fakeAsync](https://angular.io/docs/ts/latest/api/core/testing/index/fakeAsync-function.html) to test code as if it were synchronous. The promise is fulfilled immediately after you call `tick()`

{% highlight javascript %}
it('navigates to reports after submitting a report', fakeAsync(() => {
  spyOn(reportsGateway, 'saveReport')
    .and.returnValue(Promise.resolve());
  spyOn(router, 'navigate');

  component.submitReport('a report');
  tick();

  expect(reportsGateway.saveReport).toHaveBeenCalledWith('a report');
  expect(router.navigate).toHaveBeenCalledWith(['reports']);
}));
{% endhighlight %}

The test is readable, not flaky, not wasting time and passes. Great.
