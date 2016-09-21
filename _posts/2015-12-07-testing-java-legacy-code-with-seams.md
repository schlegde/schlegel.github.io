---
layout: post
title: "Make Java Legacy Code Testable via Seams"
date:   2015-12-07 19:25:33
description: ""
category:
tags: []
---
With the help of a technique called _creating a seam_, or _subclass and override_ we can make almost every piece of code testable.

The first time I've seen this practice was in an awesome screencast of Sandro Mancuso called [Testing and Refactoring Legacy Code](https://www.youtube.com/watch?v=_NnElPO5BU0). All the code snippets in this post are also taken from his screencast and shortened.

The technique is used to help cover existing functionality with tests before we start refactoring it. Remember:

<blockquote class="twitter-tweet tw-align-center" lang="en"><p lang="en" dir="ltr">If your &quot;refactoring&quot; breaks things, it&#39;s not refactoring</p>&mdash; Jason Yip (@jchyip) <a href="https://twitter.com/jchyip/status/664469905387974656">November 11, 2015</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

Let's say we have a static call inside a method which we want to unit test.

{% highlight java %}
public List<Trip> getCurrentUsersTrips() {
  ...
  User loggedInUser = UserSession.getLoggedInUser();
  ...
}
{% endhighlight %}

We have no way to mock the `UserSession` and let the `getLoggedInUser()` method return a predefined user in our test. To do this we would have to change the way `UserSession` is used and thereby change the architecture of the program. As we try to test in small steps we will resist the urge to remove the static method calls and inject the `UserSession` into our class under test. Covering the `UserSession.getLoggedInUser()` will be achieved via a seam. Let's extract the method call into a protected method:

{% highlight java %}
protected User getLoggedInUser() {
  return UserSession.getLoggedInUser();
}
{% endhighlight %}

In our test file we will then create a testable implementation of our class under test:

{% highlight java %}
private class TestableTripService extends TripService {
  @Override
  protected User getLoggedInUser() {
    return new User("Peter");
  }
}
{% endhighlight %}

Our `getLoggedInUser()` method was overridden. The rest of the implementation stays the same. Now we can return a `User` of our choice without the use of Mocks.

This will work as long as the class under test is not `final`. Since `final` classes can't be subclassed.

But beware, these seams should not stay in your codebase for long. Ultimately they should be replaced with a design that does not need seams. In the example above this would happen by avoiding static methods and using dependency injection. Creating a seam should only be regarded as an intermediary step.

<blockquote class="twitter-tweet tw-align-center" lang="en"><p lang="en" dir="ltr">When you use legacy code testing techniques to test-drive your designs, you get legacy code. This seems obvious to me.</p>&mdash; ☕ J. B. Rainsberger (@jbrains) <a href="https://twitter.com/jbrains/status/672669150003798016">December 4, 2015</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

It's a powerful technique. I've also seen it misused in a way to replace multiple lines of code at once, especially in methods that have multiple responsibilities and are often 100 lines and more in length. Please restrict their use to cases as the one above with the `UserSession`.
