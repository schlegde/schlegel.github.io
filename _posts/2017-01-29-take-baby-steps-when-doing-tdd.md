---
layout: post
title: "Take Baby Steps when doing TDD"
date:   2017-01-29 18:11:42
description: ""
category:
tags: []
---

During the [15th Meeting of the Softwerkskammer Stuttgart](https://www.softwerkskammer.org/activities/16.%20Treffen%20der%20Softwerkskammer%20Stuttgart) we approached a Kata where the goal is to create an algorithm to transform the input on the left to the output on the right.

{% highlight bash %}
Input:  -> Output:
'a'     -> 'A'
'ab'    -> 'A-Bb'
'abc'   -> 'A-Bb-Ccc'
'Kata'  -> 'K-Aa-Ttt-Aaaa'
{% endhighlight %}

In the retrospective for the exercise we learned the Kata, at the first glance hardly challenging, serves as a great example for learning to take small steps. A small step could be regarded as less than 2 minutes passing between writing the failing test and making it pass.

We recite the [Three Laws of TDD](http://blog.cleancoder.com/uncle-bob/2014/12/17/TheCyclesOfTDD.html) as a reminder.

1. You must write a failing test before you write any production code.
2. You must not write more of a test than is sufficient to fail, or fail to compile.
3. You must not write more production code than is sufficient to make the currently failing test pass.

Using JavaScript and [tape](https://github.com/substack/tape) we start out with the following test

{% highlight javascript %}
test('first character is capitalized', (assert) => {
  assert.equal(transform('a'), 'A')
  assert.end()
})
{% endhighlight %}

All it takes to make it pass is the following implementation

{% highlight javascript %}
let transform = () => {
  return 'A'
}
{% endhighlight %}

That's cheating you say, but we have to take a look at the third law of TDD above. Anything other than returning the hardcoded `'A'` would have violated the law since it would have been more than is sufficient to make the test pass.

Continuing we move the implementation towards supporting multiple characters by using [toUpperCase](https://developer.mozilla.org/en/docs/Web/JavaScript/Reference/Global_Objects/String/toUpperCase)

{% highlight javascript %}
let transform = (input) => {
  return input.toUpperCase()
}

test('first character is capitalized', (assert) => {
  assert.equal(transform('a'), 'A')
  assert.equal(transform('b'), 'B')
  assert.end()
})
{% endhighlight %}

A rash next step would be the to add the following test

{% highlight javascript %}
test('multiple characters', (assert) => {
  assert.equal(transform('ab'), 'A-Bb')
  assert.end()
})
{% endhighlight %}

As to what is the quickest way to make the above test pass. We pretty much have to create the full algorithm in one go.

Why? Because the step we took was too big. Take a breather to think. We would have to extend the algorithm by the following three features to get the test to pass

* Divide the parts with a minus
* Print the second character twice
* Only the first character in the second part is capitalized

These three features could have been revealed by giving the test a proper description. A truthful description would be as follows

{% highlight javascript %}
test('print second character twice, once uppercase, once lowercase and divided from the first character by a minus', (assert) => {
  assert.equal(transform('ab'), 'A-Bb')
  assert.end()
})
{% endhighlight %}

Quite a mouthful. Having to resort to words such as `and` in a test description makes the error blatantly obvious. If the test has multiple reasons to fail it makes it harder for you to pinpoint the introduction of bugs.

Let's continue with our broken down tests

{% highlight javascript %}
test('parts are visually divided with a minus', (assert) => {
  assert.equal(transform('ab')[1], '-')
  assert.end()
})
{% endhighlight %}

Make it pass by extending the algorithm

{% highlight javascript %}
let transform = (input) => {
  return input.toUpperCase().split('').join('-')
}
{% endhighlight %}

Continue with

{% highlight javascript %}
test('second character is printed twice in a row', (assert) => {
  assert.true(transform('ab').toLowerCase().endsWith('bb'))
  assert.end()
})
{% endhighlight %}

The fact that we have to handle every character guides us towards the introduction of a loop.

{% highlight javascript %}
let transform = (input) => {
  return input.split('').map((element, counter) => {
    return element.repeat(counter).toUpperCase()
  }).join('-')
}
{% endhighlight %}

On with the last test

{% highlight javascript %}
test('capitalize only the first character in the second part', (assert) => {
  assert.true(transform('ab').endsWith('Bb'))
  assert.end()
})
{% endhighlight %}

And make it pass

{% highlight javascript %}
let transform = (input) => {
  return input.split('').map((element, counter) => {
    return element.toUpperCase() +
      element.repeat(counter).toLowerCase()
  }).join('-')
}
{% endhighlight %}

Let's verify the implementation with a more complex test

{% highlight javascript %}
test('transformation', (assert) => {
  assert.equal(transform('Kata'), 'K-Aa-Ttt-Aaaa')
  assert.end()
})
{% endhighlight %}

It passes without changing the implementation.

To summarize:

> If you would get the test to pass by pretty much writing the whole algorithm at once consider breaking the test into smaller pieces. If you can't think of any way to break the test down try to write a more verbose description of what the test does.
