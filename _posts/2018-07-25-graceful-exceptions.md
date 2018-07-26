---
layout: post
title: "Graceful Exceptions"
date:   2018-07-25 19:32:17
description: ""
category:
tags: []
---

When creating a HTTP request we never know if the targeted resource is available. Let's look at the following example in [Kotlin](https://en.wikipedia.org/wiki/Kotlin_(programming_language)). Using [khttp](http://khttp.readthedocs.io/en/latest/) the following passes

{% highlight kotlin %}
val res = get("http://hodler.co")
assertThat(res.statusCode).isEqualTo(200)
{% endhighlight %}

Boring.
We force an error

{% highlight kotlin %}
val res = get("http://notavailablehodler.co")
assertThat(res.statusCode).isEqualTo(200)
{% endhighlight %}

Leads to

> Exception in thread "main" java.net.UnknownHostException: notavailablehodler.co

How did that happen?

Apparently `get` was supposed to return type `Response`

It did not.

We got `UnknownHostException`

How would we know, without reading its implementation or the documentation, the function might throw  `UnkownHostException`?

Yes, through experience we might guess it can fail. But not whether it will raise an Exception or return null.

Thus, if we already know something could fail shouldn't we somehow add it to the function declaration?

Using [Arrow](https://arrow-kt.io/), a functional companion to Kotlin's standard library, we create the following abstraction

{% highlight kotlin %}
fun fetchInfos(): Either<String, Response> {
    try {
        return Right(get("http://hodler.co"))
    } catch (e: Exception) {
        return Left("Something went wrong")
    }
}
{% endhighlight %}

## Either

The `Either` is a well known concept in functional programming.

It's used to signal whether an error can occur.

While `Right`, by convention, is used to hold the values of a successful execution, `Left` is used to show something went wrong. Usually in the form of an error message.

As a result the caller of the function will know from it's declaration whether a function might return an error.

It's not hidden from plain sight. We're forced to deal with it.

Usage of the function created above might look as follows

{% highlight kotlin %}
fetchInfos()
  .fold({ "Service currently not available" },
    { "Service has returned statuscode $it.status" })
{% endhighlight %}

The `fold` allows us to extract the value from `Either`. Or provide a default if it's `Left`.

Say we use the above to render a message to the user. Should `fetchInfos` return successfully by providing `Right` then the user will see

> Service has returned statuscode 200

On the other hand providing a `Left` will show

> Service currently not available

Guess all we would have to do now is to create a HTTP request library which will only return the type `Either` instead of `Response` or some kind of exception.
