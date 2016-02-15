---
layout: post
title: "Exception Testing Approaches in Java"
date:   2016-02-14 15:53:33
description: ""
category:
tags: []
---
This following blog post was inspired by [Use JUnit’s expected exceptions sparingly](http://blog.jooq.org/2016/01/20/use-junits-expected-exceptions-sparingly/). Instead of telling you what you should or should not do let's try to offer different approaches to test driving exceptions.

As an example for why we need to test exceptions we use the fabulous TDD Kata [String Calculator](http://osherove.com/tdd-kata-1/) by [Roy Osherove](https://twitter.com/royosherove). It states:

> Calling Add with a negative number will throw an exception “negatives not allowed” - and the negative that was passed.if there are multiple negatives, show all of them in the exception message

## JUnit4 - Annotation based
Using the annotation based approach the test could look as follows

{% highlight java %}
@Test(expected = RuntimeException.class)
public void does_not_allow_negative_numbers_as_input() {
  stringCalculator.add("-1");
}
{% endhighlight %}

The above is fine if we do not care what message the exception uses. Maybe we only use exceptions with descriptive names or don't test the contents of the error message at all, because if you change the content your test will break. Making it subject to change and thus brittle. The same is valid for checking if a button states `Sign up` or `Create account`. We're probably be better off testing if the button is invoking the desired functionality instead of its wording.

Nevertheless, since the Kata requires us to show all the passed negative numbers in the exception message we need another approach.

## JUnit4 - Using try-catch
The following is probably the most common approach of testing exceptions

{% highlight java %}
@Test
public void does_not_allow_negative_numbers_as_input() {
  try {
    stringCalculator.add("-1,1,-2");
    fail();
  } catch (Exception e) {
    assertThat(e.getMessage(), containsString("-1,-2");
  }
}
{% endhighlight %}

It's considered verbose and having the `fail();` adds extra complexity. The `fail();` is necessary to have a failing test, in case the exception is never thrown, as all the assertions are inside of the `catch` block. Using the structure above in multiple locations also leads to heavy code duplication.

## JUnit5 - Lambda
[JUnit5](https://github.com/junit-team/junit5), which is, at the time of this writing, in it's alpha stage. It provides the following

{% highlight java %}
@Test
public void does_not_allow_negative_numbers_as_input() {
  Throwable ex = expectThrows(RuntimeException.class, () ->
    stringCalculator.add("-1,1,-2")
  );
  assertEquals("negatives not allowed: provided -1,-2",
    ex.getMessage());
}
{% endhighlight %}

We can already use the above without adding any extra dependency by using the following helper functions

{% highlight java %}
@FunctionalInterface
public interface Executable {
  void execute() throws Exception;
}
{% endhighlight %}

{% highlight java %}
public static Throwable assertThrows(
  Class<? extends Throwable> expected, Executable executable) {
    return expectThrows(expected, executable);
}

public static <T extends Throwable> T expectThrows(
  Class<T> expectedType, Executable executable) {
  try {
    executable.execute();
  } catch (Throwable actualException) {
    if (expectedType.isInstance(actualException))
      return (T) actualException;
    else {
      String msg = String.format(
      "Unexpected exception: expected %s, got %s",
              expectedType.getName(),
              actualException.getClass().getName());
      throw new AssertionFailedError(msg);
    }
  }
  throw new AssertionFailedError("Nothing was thrown");
}
{% endhighlight %}

## AssertJ
[AssertJ](http://joel-costigliola.github.io/assertj/index.html) offers fluent assertions, which means the assertions read like English sentences.

{% highlight java %}
@Test
public void does_not_allow_negative_numbers_as_input() {
  assertThatThrownBy(() -> stringCalculator.add("-1,1,-2"))
    .isInstanceOf(RuntimeException.class)
    .hasMessageContaining("-1,-2");
}
{% endhighlight %}

Personally I prefer AssertJ due to its fluency. Use what you and your team likes or agrees on. Now you know some of the possibilities.
