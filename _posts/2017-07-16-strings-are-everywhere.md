---
layout: post
title: "Strings, Strings everywhere!"
date:   2017-07-24 10:21:23
description: ""
category:
tags: []
---

Since no blog is complete without a post on types and I recently came across a shocking piece of internal documentation we now have a great example on why using the type `String` to represent a domain concept is unwise.

The project in questions connects a plethora of third party systems. Each of these systems has some kind of id to identify a user. Let's call the identifiers `customerId` and `ownerId`. Both identify the user in their respective systems.

Turning towards the documentation of these identifiers. A stated goal of the codebase, according to the internal documentation, is

> "Avoid misleading identifiers"

In there we're shown a negative example

{% highlight java %}
/**
 * Get all {@link Foo} of a user.
 *
 * @param userId
 *      userId of user
 * @return provides all the {@link Foo} of a user
*/
List<Foo> getFoos(String userId)
{% endhighlight %}

and the positive example on how it should be done

{% highlight java %}
/**
 * Get all {@link Foo} of a user.
 *
 * @param customerId
 *      customerId of user
 * @return provides all the {@link Foo} of a user
*/
List<Foo> getFoos(String customerId)
{% endhighlight %}

We have only changed the parameter name from `userId` to `customerId`. Making it, according to the docs, easier to show the programmer it wants the userId for the customer third party system and not the userId for the owner third party system.

Let's for a second ignore the Javadoc above is just repeating the method name and to use `get` instead of a more descriptive name is probably not the neatest choice for now.

Why are we not using a special type if we're already in Java to alleviate the pain of misleading identifiers?

`CustomerId` and `OwnerId` come to mind. Let's give it a try

{% highlight java %}
public class CustomerId {
  private final String customerId;

  public CustomerId(String customerId) {
    this.customerId = customerId;
  }

  public String asString() {
    return customerId;
  }
}
{% endhighlight %}

The method above could be rewritten as

{% highlight java %}
List<Foo> fetchFoos(CustomerId customerId)
{% endhighlight %}

Besides improve documentation of what is allowed to be passed we even use the compiler to our advantage. The compiler will not allow anyone to pass a `String`. Additionally we have a simpler interface of what can be done with a `CustomerId`. A `String` can be concatenated with another `String` and offers a lot more functionality (`contains`, `endsWith`, `format`, `getBytes` to name a few). Something we probably never want to do with a UUID.

Furthermore we can throw in some validation. Especially if these identifiers have a different structure (as they have in the project). One is similar to a UUID and the other is an incrementing number with an abbreviation in front of it. Say the abbreviation in front of every `OwnerId` is `OID`, making it `OID000357`. In the real system, passing a String with the `ownerId` structure into a service requiring the `customerId` structure might not even tell you the identifier is not acceptable. Instead you get a simple `User not found` exception.

The following will offer us some additional help when constructing an `OwnerId`, helping us to avoid passing in a `String` which represents a customerId to the `OwnerId` constructor.

{% highlight java %}
public OwnerId(String ownerId) {
  if (!ownerId.startsWith("OID") {
    throw new IllegalArgumentException("ownerId is invalid.
      It does not start with OID");
  }
  this.ownerId = ownerId;
}
{% endhighlight %}

Voila, easier debugging through improved error messages.

> "Ok, great idea wrapping the strings in a domain object, but our third party interfaces take Strings!"

That's where the concept of [wrap third party classes]({% post_url 2015-11-15-do-not-mock-what-you-do-not-own %}) begins to shine.

{% highlight java %}
List<Foo> fetchFoos(CustomerId customerId) {
  thirdPartyService.getFoos(customerId.asString());
}
{% endhighlight %}

The domain object is translated back into a string right before it leaves our system. Nowhere outside of the boundaries where the `String` enters and leaves will we represent it using the type `String`.

One downside is the fact `customerId` already percolates throughout the system as a `String`. Some serious search and replace refactoring might seem in order. That's why its easier to extract domain concepts into objects rather sooner than later to avoid the mess in the first place.

