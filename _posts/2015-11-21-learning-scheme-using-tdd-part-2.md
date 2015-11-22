---
layout: post
title: "Learning Scheme with TDD - Part 2"
date:   2015-11-21 19:55:15
description: ""
category:
tags: []
---

We start with [Exercise 1.3](https://mitpress.mit.edu/sicp/full-text/book/book-Z-H-10.html#%_sec_1.1.1)

> Define a procedure that takes three numbers as arguments and returns the sum of the squares of the two larger numbers.

Let's write a test that will check the easiest case. We use three zeroes as arguments. The solution should be zero.

{% highlight scheme %}
(assert-that "added square of the largest two in (0 0 0) is 0"
  (= 0 (add-square-of-largest-two 0 0 0)))
{% endhighlight %}

The quickest way to pass this test would be to let the function return a hardcoded zero.

{% highlight scheme %}
(define (add-square-of-largest-two first-num second-num third-num) 0)
{% endhighlight %}

Now we enter the refactoring phase. The specified function signature already breaks a clean code principle. We should avoid having more than two arguments for a function. If these three arguments all belong to each other to warrant the need to be passed together then they shoul be put into another construct. We will choose a list and refactor the code as follows

{% highlight scheme %}
(assert-that "added square of largest two in 0,0,0 is 0"
  (= 0 (add-square-of-largest-two (list 0 0 0))))

(define (add-square-of-largest-two numbers) 0)
{% endhighlight %}

To get rid of the hardcoded zero we add another test.
{% highlight scheme %}
(assert-that "added square of largest two in 1,0,0 is 1"
  (= 1 (add-square-of-largest-two (list 1 0 0))))
{% endhighlight %}

One of the quickest ways to get the correct solution would be to just return the max value of the passed list.

{% highlight scheme %}
(define (add-square-of-largest-two numbers) (apply max numbers))
{% endhighlight %}

`apply` calls `max` with the elements of the following list as arguments.

As we continue with the refactoring phase we can spot duplication in the tests. We can probably extract the following into another function

{% highlight scheme %}
(= 0 (add-square-of-largest-two (list 0 0 0)))
{% endhighlight %}

The following addition to our test-code will help us in removing the duplication, shortening the assertions and making the test more readable.

{% highlight scheme %}
(define (is expected numbers)
  (= expected (add-square-of-largest-two numbers)))
{% endhighlight %}

The assertions should now look as follows:
{% highlight scheme %}
(assert-that "added square of largest two in 0,0,0"
  (is 0 (list 0 0 0)))
(assert-that "added square of largest two in 1,0,0"
  (is 1 (list 1 0 0)))
{% endhighlight %}

The fastest way to fail the next test now would be to pass a value whose square is not itself.

{% highlight scheme %}
(assert-that "added square of largest two in 2,0,0"
  (is 4 (list 2 0 0)))
{% endhighlight %}

We now have to use the `square` function

{% highlight scheme %}
(define (add-square-of-largest-two numbers)
  (square (apply max numbers)))
{% endhighlight %}

Now lets improve our tests. We can improve their readability and remove duplication.

{% highlight scheme %}
(define (assert-that actual expected)
  (if (not (= actual expected))
      (error "sum of square of largest two was not" expected)))

(define (is expected) expected)

(assert-that (add-square-of-largest-two (list 0 0 0)) (is 0))
(assert-that (add-square-of-largest-two (list 1 0 0)) (is 1))
(assert-that (add-square-of-largest-two (list 2 0 0)) (is 4))
{% endhighlight %}

I'd suggest replacing the next zero to get a failing test

{% highlight scheme %}
(assert-that (add-square-of-largest-two (list 2 1 0)) (is 5))
{% endhighlight %}

The quickest way to get it to pass is just to add the second number to the solution.

{% highlight scheme %}
(define (add-square-of-largest-two numbers)
  (+ (second numbers) (square (apply max numbers)))))
{% endhighlight %}

There is nothing to refactor so lets write a new failing test.

{% highlight scheme %}
(assert-that (add-square-of-largest-two (list 2 1 2)) (is 8))
{% endhighlight %}

Now lets sort the list by size and add the squares of the first two values.

{% highlight scheme %}
(define (sort-descending list) (sort list >))

(define (add-square-of-largest-two numbers)
  (+ (square (first (sort-descending numbers)))
     (square (second (sort-descending numbers)))))
{% endhighlight %}

I dislike the fact that we're now sorting the list twice. Let's fix it by introducing a local variable, which can be achieved with `let`.

{% highlight scheme %}
(define (add-square-of-largest-two numbers)
  (let ((sorted (sort-descending numbers)))
    (+ (square (first sorted))
     (square (second sorted)))))
{% endhighlight %}

I can't think of a test which would fail using our current implementation. We're done.

With respect to the book you could say we have _cheated_, as the concept of lists, sorting or local variables is not known at this point in the book, yet. We have also not respected what the exercise, or the customer, asked for. Our function does not take three arguments. It takes one. It's the way the tests and clean code principles have guided us.

To still achieve the requested function signature we can build a wrapper function as follows

{% highlight scheme %}
(assert-that (add-square-of-largest-two-in 2 -1 -1) (is 5))

(define (add-square-of-largest-two-in a b c)
  (add-square-of-largest-two (list a b c)))
{% endhighlight %}

Let's review the finished code

### Test
{% highlight scheme %}
(define (assert-that actual expected)
  (if (not (= actual expected))
      (error "sum of square of largest two was not" expected)))

(define (is expected) expected)

(assert-that (add-square-of-largest-two (list 0 0 0)) (is 0))
(assert-that (add-square-of-largest-two (list 1 0 0)) (is 1))
(assert-that (add-square-of-largest-two (list 2 0 0)) (is 4))
(assert-that (add-square-of-largest-two (list 2 1 0)) (is 5))
(assert-that (add-square-of-largest-two (list 2 1 2)) (is 8))
{% endhighlight %}

### Implementation
{% highlight scheme %}
(define (sort-descending list) (sort list >))

(define (add-square-of-largest-two numbers)
  (let ((sorted (sort-descending numbers)))
    (+ (square (first sorted))
     (square (second sorted)))))
{% endhighlight %}

If you want you can compare the solution with [others](http://community.schemewiki.org/?sicp-ex-1.3).

By using the test driven approach we have covered a lot of groud which should provide you a basic understanding of Scheme.
