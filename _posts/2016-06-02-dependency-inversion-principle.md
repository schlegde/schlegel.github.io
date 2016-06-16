---
layout: post
title: "Dependency Inversion Principle Applied"
date:   2016-06-02 19:37:32
description: ""
category:
tags: []
---

During the development of [Kaffeesatz](githuburl), a tool to get an overview for a git repo on which files were edited the most, i needed to tell the user how long it will probably take to get the overview. Choosing to display a progress bar in the terminal i went for the following test to verify what is sent to stdout.

{% highlight java %}

{% endhighlight %}

Seems alright, doesn't it?

These are integration tests that are testing the workings of stdout multiple times. Additionally its easy to get them wrong by forgetting to reset of the stdout redirection during in the tearDown method (Annotated with `@AfterClass`).

Having a look at [Wikipedia](wikipediaurl) we can define the _Dependency Inversion Principle_ as follows

> Higher level concepts should not depend on lower level concepts

My implementation violates the principle because the use case of providing the user a progress bar depends on the delivery mechanism of displaying the progress bar (stdout). What if we want to switch the delivery mechanism and instead display the progress bar in a GUI Framework such as [JavaFX]()? In that case we would have to modify the Class containing the usecase and rewrite the test.

Let's try to decouple the use case from the delivery mechanism by putting an interface in between.

// add picture with graphviz/dot showing the flow of information?

{% highlight java %}
public interface Printer {
  void print(String toPrint);
}
{% endhighlight %}

We can now make do with a single integration test

{% highlight java %}
public class ConsolePrinterIT {

  @Test
  public void printToConsole() {
    ByteArrayOutputStream sysOutputContent = new ByteArrayOutputStream();
    System.setOut(new PrintStream(sysOutputContent));
    Printer p = new ConsolePrinter();

    p.print("hello");

    assertThat(sysOutputContent.toString(), is("hello"));
    System.setOut(new PrintStream(new FileOutputStream(FileDescriptor.out)));
  }

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

Now we have created an abstraction for the writing to stdout. The correct usage of the interface in the implementation of the progress bar can be tested by using a Spy. Using [Mockito]() it will look as follows.

{% highlight java %}

{% endhighlight %}
