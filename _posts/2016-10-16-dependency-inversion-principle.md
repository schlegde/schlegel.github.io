---
layout: post
title: "Dependency Inversion Principle Applied"
date:   2016-10-16 19:37:32
description: ""
category:
tags: []
---

During the development of [Kaffeesatz](https://github.com/axelhodler/kaffeesatz), a tool to take a Git Repository and get an overview on which files were edited the most, to identify which files could be candidates for a refactoring or are suspected to violate the [Single Responsibility Principle](https://en.wikipedia.org/wiki/Single_responsibility_principle), I wanted to show the user a visual cue on the progress of going through the history of the repository before he is able to see the report.

I chose to display a progress bar in the terminal which will look as follows in the case where 30% of the report is completed

{% highlight bash %}
|===>      |
{% endhighlight %}

To verify what is printed to _stdout_ we can use the following test

{% highlight java %}
ByteArrayOutputStream sysOutputContent;

@Before
public void setUp() {
  sysOutputContent = new ByteArrayOutputStream();
  // Redirect stdout to check what is printed
  System.setOut(new PrintStream(sysOutputContent));

  progressBar = new DisplayProgressBar();
}

...

@Test
public void display30Precent() {
  progressBar.withPercentageDone(new Progress(30));

  assertThat(sysOutputContent.toString(), is("|===>      |\r"));
}

...

@After
public void cleanUp() {
  System.setOut(null);
}
{% endhighlight %}

Additionally one should not forget to reset the _stdout_ redirection in the `tearDown` method.

{% highlight java %}
System.setOut(new PrintStream(
  new FileOutputStream(FileDescriptor.out))
{% endhighlight %}

Done. The progress bar display is tested and everything seems fine.

But... The tests above are integration-tests which are testing the workings of _stdout_ multiple times although we should probably trust the correctness of Java libraries. We also do not have any idea `DisplayProgressBar` has a dependency on _stdout_. Usually dependencies of a class are made visible by passing them into the constructor of the class. Which, as a result, allows to replace the dependency during testing or, if its an interface, with a class implementing the interface.  This does not happen in the above case. The class violates the Dependency Inversion Principle.

Having a look at [Wikipedia](https://en.wikipedia.org/wiki/Dependency_inversion_principle) we can define the _Dependency Inversion Principle_ as follows:

> High-level modules should not depend on low-level modules. Both should depend on abstractions.

_High-level modules_ in this case is the business logic of giving the user feedback on the progress of an operation. Low-level modules here is the _how_ we provide the progress to the user.

The current implementation of `DisplayProgressBar` violates the principle because the use case of "providing progress to the user" depends on the delivery mechanism of displaying the progress bar. In our case the delivery mechanism is _stdout_.

What if we want to replace the delivery mechanism and instead display the progress bar as HTML in a web-app? In that case we would have to modify the class containing the use-case and rewrite the test.

Let's try to decouple the use case from the delivery mechanism by putting an interface in-between.

{% highlight java %}
public interface Display{
  void display(String toDisplay);
}
{% endhighlight %}

Let's create an implementation of the `Display` interface.

{% highlight java %}
public class ConsoleDisplay implements Display {
  @Override
  public void display(String toDisplay) {
    System.out.print(toPrint);
  }
}
{% endhighlight %}

We can now make do with a single integration test which tests _if_ something can be printed at all.

{% highlight java %}
public class ConsoleDisplayIntegrationTest {

  @Test
  public void printToConsole() {
    ByteArrayOutputStream sysOutputContent =
      new ByteArrayOutputStream();
    System.setOut(new PrintStream(sysOutputContent));
    Display d = new ConsoleDisplay();

    d.display("hello");

    assertThat(sysOutputContent.toString(), is("hello"));
    System.setOut(new PrintStream(
      new FileOutputStream(FileDescriptor.out)));
  }

}
{% endhighlight %}

Thus we have created an abstraction for writing to _stdout_. The correct usage of the interface in the implementation of the progress bar can be tested by using a Spy. Using the mocking framework [Mockito](http://mockito.org/) it will look as follows

{% highlight java %}
@Mock
Display display;

DisplayProgressBar progressBar;

@Before
public void setUp() {
  progressBar = new DisplayProgressBar(display);
}

...

@Test
public void display30Precent() {
  progressBar.withPercentageDone(new Progress(30));

  verify(display).display("|===>      |\r");
}

...
{% endhighlight %}

Quite concise and less opportunity for errors. The dependency on a `Display` becomes visible and the Dependency Inversion Principle is not violated anymore.
