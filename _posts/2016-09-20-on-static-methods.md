---
layout: post
title: "On Static Methods"
date:   2016-09-20 23:41:33
description: ""
category:
tags: []
---
Recently I got asked by a co-worker on how he would go about testing the invocation of a static method in some legacy codebase. Not as easy as one might guess initially. We went for the [Subclass and Override Technique]({% post_url 2015-12-07-testing-java-legacy-code-with-seams %}). Of course a conversation on whether `static` should be used at all. After all you need special techniques or tools such as [PowerMock](https://github.com/jayway/powermock) to test them or create wrappers as described in [Don't Mock What You Do Not Own]({% post_url 2015-11-15-do-not-mock-what-you-do-not-own %}).

The discussion on `static` has been had multiple times all over the internet. The answer is usually the following:

> There are times when using static is fine and times when it's not.

Thus were stuck with the usual `It depends` answer.

I believe one of the best answers to the discussion was provided by Misko Hevery in a comment to his post [Static Methods are Death to Testability](http://misko.hevery.com/2008/12/15/static-methods-are-death-to-testability/). To [quote](http://misko.hevery.com/2008/12/15/static-methods-are-death-to-testability/#comment-1029):

> [...] the issue I have is that static methods are acceptable in weird conditions which I and you understand. Than [sic] a new developer shows up and does not understand the complex nature of static methods testability and thinks stitic [sic] methods are ok. It creates a slippery slope in which he can modify it and what once was an testable static method becomes untestable. I don’t want to have to explain this to people. There is zero cost to have that private method non-static, and I don’t want to have a debate with people when there are ok times. It is much easier to say no static methods allowed since what you are loosing is so little, and what you are preventing from happening is so much. An excellent trade.

I agree. There are usually way more important things to discuss in a team than whether or not to use some controversial features of Java.

Additionally, by avoiding the `static` keyword, we have evaded the [Evil](http://c2.com/cgi/wiki?SingletonsAreEvil) or [Stupid](https://sites.google.com/site/steveyegge2/singleton-considered-stupid) Singleton, which must [Die](http://www.yegor256.com/2016/06/27/singletons-must-die.html) from our codebase and improved testability even further.
