---
layout: post
title: "Dependency Inversion Principle Applied"
date:   2016-10-16 19:37:32
description: ""
category:
tags: []
---

During the development of [Kaffeesatz](https://github.com/axelhodler/kaffeesatz), a tool to take a Git Repository and get an overview on which files were edited the most, to identify which files could be candidates for a refactoring or are suspected to violate the [Single Responsibility Principle](https://en.wikipedia.org/wiki/Single_responsibility_principle), I wanted to show the user a visual cue on the progress of going through the history of the repository to create the report.

Choosing to display a progress bar in the terminal I went for the following test to verify what is printed to stdout

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

Additionally one should not forget to reset the `stdout` redirection in the `tearDown` method.

{% highlight java %}
System.setOut(new PrintStream(
  new FileOutputStream(FileDescriptor.out))
{% endhighlight %}

Done. The the progress bar display is tested and everything seems fine.

But... The tests above are integration-tests which are testing the workings of stdout multiple times although we should probably trust the correctness of Java libraries. We also do not have any idea `DisplayProgressBar` has a dependency on `stdout`. Usually dependencies of a class are made visible by passing them into the constructor of the class. Also allowing to replace it during testing or, if its an interface, with a class implementing the interface.  This does not happen in the above case. The class violates the Dependency Inversion Principle.

Having a look at [Wikipedia](https://en.wikipedia.org/wiki/Dependency_inversion_principle) we can define the _Dependency Inversion Principle_ as follows:

> High-level modules should not depend on low-level modules. Both should depend on abstractions.

> Abstractions should not depend on details. Details should depend on abstractions.

_High-level modules_ in this case is the business logic of giving the user feedback on the progress of an operation. Low-level modules here is the _how_ we provide the progress to the user.

The current implementation of `DisplayProgressBar` violates the principle because the use case of providing the user the progress depends on the delivery mechanism of displaying the progress bar. In our case the delivery mechanism is `stdout`.

What if we want to replace the delivery mechanism and instead display the progress bar in a web-app, rendered in HTML, or in a GUI Framework such as [JavaFX](http://docs.oracle.com/javafx/2/ui_controls/progress.htm)? In that case we would have to modify the class containing the use-case and rewrite the test.

Let's try to decouple the use case from the delivery mechanism by putting an interface in-between.

{% highlight java %}
public interface Printer {
  void print(String toPrint);
}
{% endhighlight %}

Let's create an implementation of the `Printer` interface.

{% highlight java %}
public class ConsolePrinter implements Printer {
  @Override
  public void print(String toPrint) {
    System.out.print(toPrint);
  }
}
{% endhighlight %}

We can now make do with a single integration test which tests _if_ something can be printed at all.

{% highlight java %}
public class ConsolePrinterIntegrationTest {

  @Test
  public void printToConsole() {
    ByteArrayOutputStream sysOutputContent =
      new ByteArrayOutputStream();
    System.setOut(new PrintStream(sysOutputContent));
    Printer p = new ConsolePrinter();

    p.print("hello");

    assertThat(sysOutputContent.toString(), is("hello"));
    System.setOut(new PrintStream(
      new FileOutputStream(FileDescriptor.out)));
  }

}
{% endhighlight %}

Thus we have created an abstraction for writing to `stdout`. The correct usage of the interface in the implementation of the progress bar can be tested by using a Spy. Using the mocking framework [Mockito](http://mockito.org/) it will look as follows

{% highlight java %}
@Mock
Printer printer

DisplayProgressBar progressBar;

@Before
public void setUp() {
  progressBar = new DisplayProgressBar(printer);
}

...

@Test
public void display30Precent() {
  progressBar.withPercentageDone(new Progress(30));

  verify(printer).print("|===>      |\r");
}

...
{% endhighlight %}

Quite concise and less opportunity for errors. The dependency on a `Printer` becomes visible and the Dependency Inversion Principle is not violated anymore.
