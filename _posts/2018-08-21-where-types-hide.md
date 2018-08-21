---
layout: post
title: "Types hiding in plain sight"
date:   2018-08-21
description: ""
category:
tags: []
---

Recently I came across something similar to the following piece of code

{% highlight kotlin %}
fun doSthWith(segment: List<Int>) {
    Assert.isTrue(segment.size == 3,
      "Segment needs to have a size of exactly 3")

    // Some logic follows
}
{% endhighlight %}

What the function does is irrelevant. All we need to know for now is it will throw an `IllegalArgumentException` if there are not exactly three `Int` in the `segment`.

Thus it makes sure the implementation can work with the provided input.

Without going into the domain any further the assertion above is screaming we have a type in hiding. `List<Int>` should be an explicit type of our domain.

Thus we avoid having a caller run into the `IllegalArgumentException` or to depend on the correctness or presence of the `doSthWith` documentation.

Let's create what is less verbose in Kotlin than in Java.

A type.

{% highlight kotlin %}
data class ThreeItemSegment(val first: Int,
                            val second: Int,
                            val third: Int)
{% endhighlight %}

Of course in reality the type would resemble a concept of the domain of our application. The name above is just an example. It's less code than writing the assertion and makes sure the values are not `null` by using the `val` keyword.

The brevity of the Kotlin class should swiftly deal with the well known

> But creating an extra class for one method signature is so much overhead!

argument.

We can evolve our function into

{% highlight kotlin %}
fun doSthWith(segment: ThreeItemSegment) {
    // Some logic follows
}
{% endhighlight %}

The assertion is not necessary anymore. Our compiler enforces the input we pass is valid.

As a result the function has become easier to use and is easier to reason about.

Yay types!

