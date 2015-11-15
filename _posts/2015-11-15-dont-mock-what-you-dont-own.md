---
layout: post
title: "Don't Mock What You Don't Own"
date:   2015-11-15 19:18:32
description: ""
category:
tags: []
---

Recently i had a discussion with a coworker about the guideline:

> Don't mock what you don't own

Which, summarized, means you should not mock interfaces or types of external libraries or even your runtime. Still, you will want to mock these dependencies while you test drive your code. As a solution you should create wrappers around these external classes and mock the wrapper.

{% highlight java %}
public class Wrapper {
  private ExternalObject wrappedObject;

  public Wrapper() {
    wrappedObject = new ExternalObject();
  }

  public void doSomething() {
    wrappedObject.doSth();
  }
}
{% endhighlight %}

This is usually first met with uncertainty. Isn't the primary use case of mocks to fake classes that talk to databases or the network? Well, lets look at the benefits of wrapping these dependencies:

* Your design will be decoupled from the external dependency, which will make it easier to replace the dependency or to defer the decision which library, if one at all, you want to use.
* Creating these wrappers will allow you to hide the complexity of the library. Maybe you only need three out of the twenty methods the interface offers. Which means you only need to wrap these three.
* You will be able to use your domain language as described [here](http://blog.8thlight.com/eric-smith/2011/10/27/thats-not-yours.html). Basically it shows how by using the opportunity to wrap the external object you can let it express your internal domain by choosing the classname and the methodnames of the methods you decide to wrap.
* In some cases only wrapping the objects will make mocking possible. [Mockito](http://mockito.org/) will not allow you to verify calls on final methods. By wrapping these final methods you can verify interactions with them without having to use tools such as [PowerMock](https://github.com/jayway/powermock).

To make sure your code will actually store something in the database, not just verify that the method to store something is called, you will make use of integration tests which will test the boundaries between your wrappers and the external library. See [Hexagonal Architecture](http://alistair.cockburn.us/Hexagonal+architecture).
