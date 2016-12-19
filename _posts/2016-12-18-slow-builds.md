---
layout: post
title: "Slow Builds"
date:   2016-12-19 12:50:17
description: ""
category:
tags: []
---

In one of the codebases I'm working on a clean build takes around 90 minutes. As a result, in a code review scenario with branches, it takes 90 minutes for the branch to build and after the merge another 90 minutes for the build in the master branch. Thus in the best case, not counting potential fixes to the branch or issues found during the code review, it takes at least 3 hours to go from a change introduced in the codebase to a production ready artifact. The customer has to wait for at least 3 hours and often more for a bug fix. It's awful.

Recently, in order to ship a feature in time, a piece of code, which belongs into the server, had to be introduced into one of the clients. Why? The build duration of the client was _only_ 10 minutes and we could avoid having to trigger the 3 hour cycle of the back-end.

It was the first time I have immediately noticed how a slow build in Project A influences the integrity of Project B. Now we have a piece of code in one of the clients which would belong into the server and a new backlog ticket to move it there.

## Why is the build slow?

Usually it boils down to integrated tests. The tests are hitting the REST-API, invoking messages getting passed through the whole system and changing the state of a database. These tests are slow. Even worse they trigger the same functionality again and again. Each time a call reaches beyond the REST-API the authentication mechanism has to be invoked. Thus each HTTP-Request could lead to a read in the database to compare the hashed password or a way to validate the token or the session id.

Another example is having an actual file uploaded, parsed and saved to the database fifty times in a row to validate business logic which states:

> the free-tier user class can only upload 50 files

Enjoy waiting.

But, how often are you supposed to test the file-upload or the authentication?

__Exactly once__.

In all but one test the login mechanism can be stubbed out since we already know it works. As for the file-upload amount use case, we test the file-upload once in isolation and have a unit test similar to the following:

{% highlight java %}
@Test
public void onlyAllowFiftyFileuploadsForFreemiumUsers() {
  User user = new User("Fiona the FreemiumUser");

  user.setFileCount(50);

  assertFalse(user.canUploadMoreFiles());
}
{% endhighlight %}

Voila. What once took 30 seconds does now take less than one second.

We continue with the dreaded `Thread.sleep(5000)`. If you check the git history where the `Thread.sleep` is used you will probably see a commit message along the lines of

{% highlight bash%}
FOO-42: increase duration to avoid flaky tests
{% endhighlight %}

Imagine what you are waiting for takes _only_ 1 second but the test is waiting another 4 seconds just to make sure. These durations add up. If you really have to wait for something then try to have a loop that checks if something is done and if not you sleep additional 100ms or work with `notify` and `wait`. Even better, ask yourself if the test really needs to invoke external services and wait for them to resolve or if a `Mock` would be a better way to check if some URL was called and to instantly return a stubbed result. Its usually a good thing to have a build which is not connecting to external services on the internet. One way to prove this is to remove the internet connection and see if the build is still successful. Else, especially on a flaky internet connection, you will experience build failures all the time because some external service could not be reached.

If the test duration is down to a minute consider reading [TDD, Straw Men, and Rhetoric](https://www.destroyallsoftware.com/blog/2014/tdd-straw-men-and-rhetoric), where the benefits of having a test suite which runs in under a second are displayed.

Another time thief is doing things during a build which should be extracted into another build. One example would be documentation which takes some `.tex` and `.md` files to generate `.pdf` and `.html` output. It can easily take a few minutes depending on the size of the documentation.

If the build is still slow after all the above has been fixed have a look at which parts usually change together and extract them into a separate codebase which is referenced as a dependency or a git submodule.

A project does not suddenly have a build duration of 90 minutes. It takes months or years to create it. In my experience i'ts a widespread pain point of a project to have a slow build. Talk with your team, find the bottlenecks and start to improve them.
