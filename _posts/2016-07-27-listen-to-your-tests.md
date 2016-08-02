---
layout: post
title: "Listen to your tests"
date:   2016-07-27 23:41:33
description: ""
category:
tags: []
---
Recently I encountered a piece of code that, in effect,
although a lot more verbose, did something along the
following lines

{% highlight java %}
public void addAllowedOperations(User user) {
  Set<UserOperation> operations =
    securityService.fetchAllowedOperationsFor(user);
  user.setAllowedOperations(operations);
}
{% endhighlight %}

All allowed operations for the a `user` are fetched and added to it.

Suppose we need a `User` with her `allowedOperations` in another class
and achieve this by reusing the method above. In the Unit Test of the other
class we would then be stubbing the method `addAllowedOperations` to provide us with the `User`
with the `allowedOperations` already set.

Stubbing methods which return something, using the [Mockito](http://mockito.org/)
BDD syntax, looks as follows

{% highlight java %}
User userStub = new User();
userStub.setAllowedOperations(UserOperation.DELETE_USER,
    UserOperation.BUY_STOCKS);

given(service.addAllowedOperations(user)
  .willReturn(userStub));
{% endhighlight %}

Because `addAllowedOperations` does not return anything and instead
mutates the argument `user`, we can't use the `given` `willReturn` structure above.

We need to use the Mockito `Answer` feature

{% highlight java %}
willAnswer(invocation -> {
  User userStub = (User) invocation.getArguments()[0];
  userStub.setAllowedOperations(UserOperation.DELETE_USER,
      UserOperation.BUY_STOCKS));
  return null;
}).given(service)
    .addAllowedOperations(userStub);
{% endhighlight %}

It does not look as straightforward as `given` and `willReturn` anymore.
In fact I had to check the documentation to find out the Mockito syntax
for this apparent _sorcery_.

What I'm hinting at is even if we don't yet know what
[Side-Effects](http://blog.jenkster.com/2015/12/what-is-functional-programming.html) are or which benefits
[Immutability](https://en.wikipedia.org/wiki/Immutable_object) brings to the table, you are left with a sense that
something is awry here.

Thus by taking into account the added complexity of the test setup a 
developer might, in the future, opt for a design which is easier to 
test. Even if the method simply returns the mutated `App` object instead
of `void`.