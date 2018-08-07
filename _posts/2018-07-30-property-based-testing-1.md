---
layout: post
title: "Property Based Testing I"
date:   2018-07-30 19:32:17
description: ""
category:
tags: []
---

Property based testing is often introduced by using the implementation of an `add` method. The `add` method is supposed to add two numbers.

Thus `add(1,1)` should yield `2` and `add(42, 1337)` should yield `1379`.

To [test drive](https://en.wikipedia.org/wiki/Test-driven_development) the implementation one might start with a simple test case

{% highlight java %}
@Test
public void adds_two_numbers() {
  assertThat(add(0, 0)).isEqualTo(0);
}
{% endhighlight %}

We're making the test pass with the simplest implementation

{% highlight java %}
public static int add(int a, int b) {
  return 0;
}
{% endhighlight %}

Ok. If all we ever do is adding zeroes the above is enough.

Let's drive out a smarter implementation

{% highlight java %}
@Test
public void adds_two_numbers() {
  assertThat(add(0, 0)).isEqualTo(0);
  assertThat(add(1, 0)).isEqualTo(1);
}
{% endhighlight %}

And quickly pass the tests with

{% highlight java %}
public static int add(int a, int b) {
  if (a == 1) {
    return 1;
  }
  return 0;
}
{% endhighlight %}

Well... guess then we'll go for

{% highlight java %}
@Test
public void adds_two_numbers() {
  assertThat(add(0, 0)).isEqualTo(0);
  assertThat(add(1, 0)).isEqualTo(1);
  assertThat(add(2, 0)).isEqualTo(2);
}
{% endhighlight %}

Try harder

{% highlight java %}
public static int add(int a, int b) {
  if (a != 0) {
    return a;
  }
  return 0;
}
{% endhighlight %}

Ok

{% highlight java %}
@Test
public void adds_two_numbers() {
  assertThat(add(0, 0)).isEqualTo(0);
  assertThat(add(1, 0)).isEqualTo(1);
  assertThat(add(2, 0)).isEqualTo(2);
  assertThat(add(2, 1)).isEqualTo(3);
}
{% endhighlight %}

Easy peasy

{% highlight java %}
public static int add(int a, int b) {
  if (a == 2 && b == 1) {
    return 2;
  }
  if (a != 0) {
    return a;
  }
  return 0;
}
{% endhighlight %}

Ah come on.

Let's stop this nonsense.

That's usually the point where a property based testing library such as [junit-quickcheck](https://github.com/pholser/junit-quickcheck) is introduced and the tests are rewritten as follows

{% highlight java %}
@RunWith(JUnitQuickcheck.class)
public class AddTest {

  @Property
  public void adds_two_numbers(
        @InRange(min = "0", max = "100") int a,
        @InRange(min = "0", max = "100") int b) {
    assertThat(add(a, b)).isEqualTo(a + b);
  }

}
{% endhighlight %}

The `@Property` annotation will make sure the test is run multiple times. 100 times by default. While `@InRange` will generate random values inside of the specified boundaries using `min` and `max`.

Because it is way to hard to have a bad implementation to catch all the random value we're ultimately forced to give up and write the proper implementation.

{% highlight java %}
public static int add(int a, int b) {
  return a + b;
}
{% endhighlight %}

We did it. Marvelous. Property based testing rules. Everyone is happy.

Though there are a few issues with the way the concept was taught.

We're going step through some of them.

### The laws of TDD were not followed

Not once has there been a refactoring step. We went through phases in a manner of `Red -> Green -> Red -> Green -> Red [...]`.

The refactoring step was missing completely.

Additionally the rule [As the tests get more specific, the production code gets more generic](http://blog.cleancoder.com/uncle-bob/2017/03/03/TDD-Harms-Architecture.html) was not applied.

After seeing the following monstrosity

{% highlight java %}
public static int add(int a, int b) {
  if (a == 2 && b == 1) {
    return 2;
  }
  if (a != 0) {
    return a;
  }
  return 0;
}
{% endhighlight %}

a refactoring step and a bit of thinking would have led us to

{% highlight java %}
public static int add(int a, int b) {
  if (a != 0) {
    return a + b;
  }
  return 0;
}
{% endhighlight %}

and subsequently help to recognize we might be able to drop the whole `if` nonsense

{% highlight java %}
public static int add(int a, int b) {
  return a + b;
}
{% endhighlight %}

Voilà

### No one homebrews their own add function

Our standard library will usually offer it out of the box.

Take [Haskell](https://en.wikipedia.org/wiki/Haskell_(programming_language))

{% highlight bash %}
λ> 2 + 2
4
{% endhighlight %}

or [Python](https://en.wikipedia.org/wiki/Python_(programming_language))

{% highlight python %}
>>> 2 + 2
4
{% endhighlight %}

and of course [Ruby](https://en.wikipedia.org/wiki/Ruby_(programming_language))

{% highlight ruby %}
irb(main):001:0> 2 + 2
=> 2
{% endhighlight %}

Ok. Adding might be a stupid example. But so is _reversing an array_ used in the official [docs of QuickCheck](http://www.cse.chalmers.se/~rjmh/QuickCheck/manual_body.html#3), the mother of all property based testing libraries.

Again in Haskell, Python and Ruby
{% highlight bash %}
λ> reverse [1, 2, 3]
[3,2,1]
{% endhighlight %}

{% highlight bash %}
>>> [1,2,3][::-1]
[3, 2, 1]
{% endhighlight %}

{% highlight bash %}
irb(main):001:0> [1,2,3].reverse
=> [3, 2, 1]
{% endhighlight %}

### The assertion duplicates the algorithm

As seen above in the test annotated with `@Property`

{% highlight java %}
assertThat(add(a, b)).isEqualTo(a + b);
{% endhighlight %}

The only difference is we have the implementation hidden behind the `add` method.

### Summary

All the above might leave the person new to property based testing in a mood of having learned something new, which is great, but having no direct target to apply the gained knowledge to.

Once, after seeing a presentation on the topic, I have asked the speaker in private if he's using property based testing in his day to day projects. The answer has been no.

As a result you might guess I have an inherent distaste for property based testing.

Nothing could be further from the truth.

In part 2 we will have a look into cases where it does make sense.
