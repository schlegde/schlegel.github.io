---
layout: post
title: "Java String and StringBuilder"
date:   2015-09-26 22:05:15
description: ""
category:
tags: []
---

Recently we had a short discussion about the usage of `StringBuilder` and basic String Concatenation via `+`. I have always found using String Concatenation more readable (when using a small amount of arguments to concatenate) and also friendlier towards newcomers to the Java ecosystem. On the other hand users of `StringBuilder` argument with a superior performance compared to String Concatenation. Not being sure about the performance issue but remembering having heard the Java compiler will optimize String Concatenation by using StringBuilder anyway i wanted to see this for myself.

Let's compile the following two snippets with `javac`:

{% highlight java %}
public class StringTesting {
    public static void main(String args[]) {
        String foo = "Hello";
        String baz = "world";

        String output = foo + " " + baz;

        System.out.println(output);
    }
}
{% endhighlight %}

{% highlight java %}
public class StringBuilderTesting {
    public static void main(String args[]) {
        String foo = "Hello";
        String baz = "world";

        String output = new StringBuilder()
                                  .append(foo)
                                  .append(" ")
                                  .append(baz)
                                  .toString();

        System.out.println(output);
    }
}
{% endhighlight %}

```
javac StringTesting.java StringBuilderTesting.java
```

We can now analyze the created bytecode with the class file disassembler `javap`, `-c` prints out the disassembled code.

```
javap -c StringTesting StringBuilderTesting
```

{% highlight bash %}
Compiled from "StringTesting.java"
public class StringTesting {
  public StringTesting();
    Code:
       0: aload_0
       1: invokespecial #1 // Method java/lang/Object."<init>":()V
       4: return

  public static void main(java.lang.String[]);
    Code:
       0: ldc           #2  // String Hello
       2: astore_1
       3: ldc           #3  // String world
       5: astore_2
       6: new           #4  // class java/lang/StringBuilder
       9: dup
      10: invokespecial #5  // Method java/lang/StringBuilder.[...]
      13: aload_1
      14: invokevirtual #6  // Method java/lang/StringBuilder.ap[...]
      17: ldc           #7  // String
      19: invokevirtual #6  // Method java/lang/StringBuilder.ap[...]
      22: aload_2
      23: invokevirtual #6  // Method java/lang/StringBuilder.ap[...]
      26: invokevirtual #8  // Method java/lang/StringBuilder.to[...]
      29: astore_3
      30: getstatic     #9  // Field java/lang/System.out:Ljava/[...]
      33: aload_3
      34: invokevirtual #10 // Method java/io/PrintStream.printl[...]
      37: return
}
{% endhighlight %}

{% highlight bash %}
Compiled from "StringBuilderTesting.java"
public class StringBuilderTesting {
  public StringBuilderTesting();
    Code:
       0: aload_0
       1: invokespecial #1  // Method java/lang/Object."<init>":()V
       4: return

  public static void main(java.lang.String[]);
    Code:
       0: ldc           #2  // String Hello
       2: astore_1
       3: ldc           #3  // String world
       5: astore_2
       6: new           #4  // class java/lang/StringBuilder
       9: dup
      10: invokespecial #5  // Method java/lang/StringBuilder."<[...]
      13: aload_1
      14: invokevirtual #6  // Method java/lang/StringBuilder.ap[...]
      17: ldc           #7  // String
      19: invokevirtual #6  // Method java/lang/StringBuilder.ap[...]
      22: aload_2
      23: invokevirtual #6  // Method java/lang/StringBuilder.ap[...]
      26: invokevirtual #8  // Method java/lang/StringBuilder.to[...]
      29: astore_3
      30: getstatic     #9  // Field java/lang/System.out:Ljava/[...]
      33: aload_3
      34: invokevirtual #10 // Method java/io/PrintStream.printl[...]
      37: return
}
{% endhighlight %}

As you can see there is no difference between the two classes on the bytecode level. The compiler automatically used the StringBuilder internally for String concatenation. There will be no difference performance wise.

The official docs [support that statement](http://docs.oracle.com/javase/specs/jls/se8/html/jls-15.html#jls-15.18.1) where the following is written:

> To increase the performance of repeated string concatenation, a Java compiler may use the StringBuffer class or a similar technique to reduce the number of intermediate String objects that are created by evaluation of an expression.

That being said, if performance is an issue you should use `StringBuilder` when constructing Strings inside of loops. The compiler won't optimize this.

Nevertheless, if the coding standards for the project dictates to use `StringBuilder` to e.g. implement the `toString()` method you can automate this in eclipse by using `Generate toString()...` and change the codestyle to use `StringBuilder/StringBuffer`.
