---
layout: post
title: "Learning Scheme with TDD"
date:   2015-11-19 20:41:15
description: ""
category:
tags: []
---

For some time now i wanted take a dive into functional programming by working through the [SICP Book](https://mitpress.mit.edu/sicp/full-text/book/book.html), which is a classic text in computer science and older than myself. The examples in the book are using [Scheme](https://en.wikipedia.org/wiki/Scheme_(programming_language). Scheme follows a minimalist design philosophy by specifying a small standard core with powerful tools for language extension.

Intrigued by a [screencast](https://www.youtube.com/watch?v=nIonZ6-4nuU) in which Kent Beck uses [TDD](https://en.wikipedia.org/wiki/Test-driven_development) to learn [coffeescript](https://en.wikipedia.org/wiki/CoffeeScript) i wanted to take a similar approach to learning Scheme.

In the following paragraphs i will describe the necessary setup steps to work through the examples following TDD.

## Unit Testing Setup
A search for `Scheme` and `Unit Testing` will lead you to [Ward Cunninghams Wiki](http://c2.com/cgi/wiki?SchemeUnit). With the infos there we can put together a simple unit testing 'framework'.

{% highlight scheme %}
(define (report-error msg)
  (error (string-append "assertion: '" msg "' has failed")))

(define (assert-that msg assertion)
  (if (not assertion) (report-error msg)))
{% endhighlight %}

Let's deconstruct the provided snippet.

{% highlight scheme %}
(define (report-error msg)
  (error (string-append "assertion: '" msg "' has failed")))
)
{% endhighlight %}

As you might have guessed, this method is for providing error messages. The `string-append` function takes strings as arguments and concatenates them to a single string. It will construct our error message. `error` takes a string and creates an actual error. With `define` we can define the function `report-error` which takes the custom part of our error message as an argument.

{% highlight scheme %}
(define (assert-that msg assertion)
  (if (not assertion) (report-error msg)))
{% endhighlight %}

The second function will provide us with the function `assert-that` to make assertions. `not` will return true if the argument is false and false if the argument is true.

{% highlight scheme %}
(not (> 1 2))
{% endhighlight %}

Will therfore return `#t` since 2 is not less than 1.

This means that if our assertion is false then `(not assertion)` will return `#t`, `report-error` will be invoked and we're left with the AssertionError.
