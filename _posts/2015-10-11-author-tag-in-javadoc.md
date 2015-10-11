---
layout: post
title: "@author tags in javadoc"
date:   2015-10-11 14:50:15
description: "A quick look on the issues around the @author tag"
category:
tags: []
---

Let's have a look at the `@author` tag provided by javadoc and why i think you should not use it at all.

{% highlight java %}
/**
* @author John Doe
*/
public class User {

}
{% endhighlight %}

This will add an "Author" entry to the generated docs. It's also likely to be a comma separated list of authors. Which leads to the fact that if you change the file you should probably also add your name to the tag. Sometimes there is no author tag at all and in some files the author has not been working in the company for years, although the class keeps being changed by other developers without updating the `@author` tag.

Why then should we put any effort into maintaining the `@author` tag if it is not telling the truth half of the time?

After all, we can use version control to find out the authors of a file:

{% highlight bash %}
git shortlog -s $filename | cut -f2
{% endhighlight %}

The [oracle documentation](http://www.oracle.com/technetwork/java/javase/documentation/index-137868.html#@author) supports this notion:

> The @author tag is not critical, because it is not included when generating the API specification, and so it is seen only by those viewing the source code. (Version history can also be used for determining contributors for internal purposes.)

[Drools](http://www.drools.org/), a Business Rules Management System, at the time of writing, use their whole [Developer FAQ](https://github.com/droolsjbpm/droolsjbpm-build-bootstrap/blob/master/README.md#faq) to explaining why they do not accept `@author` lines in their source code.

As an explanation they state that author tags in java files are a maintenance nightmare since a large percentage is wrong, incomplete or inaccurate as most of the time it only contains the original author.

They also mention __code ownership__, a bad practice that is promoted by author tags. If people work on a piece they perceive as being owned by someone else, they tend to only fix what they are assigned to fix, instead of everything that's broken. It also leads to fear to stepping on the feet of the owner and discarding of responsibility. Maybe you have heard something along the lines of the following statement:

> It's Pete's code, not mine, he has to fix it, he will be back from Spain in two weeks.

As a summary, unless you have a company policy that enforces the use of `@author` tags for whatever reason, i would suggest not using the tag at all.

Even when ignoring the arguments provided above, it's one less of the things the developer has to constantly juggle in his mind, which creates space for more important practices.
