---
layout: post
title: "Immutability"
date:   2018-06-29 12:02:17
description: ""
category:
tags: []
---

Take the following example in [Java](https://en.wikipedia.org/wiki/Java_(programming_language))

{% highlight java %}
private List<String> allowedUsers = asList("Alice", "Bob", "Charlie");

public List<String> getAllowedUsers() {
    return allowedUsers;
}

public boolean canUserAccessResource(String username) {
    return this.getAllowedUsers().contains(username);
}
{% endhighlight %}
A more verbose version can be found in the excellent course on [Programming Languages on Coursera](https://www.coursera.org/learn/programming-languages/lecture/aOQ26/optional-java-mutation)
 
What's the issue with the code above? Try to think about if for a few seconds.

Our `allowedUsers` can be modified to allow access to users which were not specified as allowed by the original author.

Tests display the the issue at hand

{% highlight java %}
@Test
public void mallory_cant_directly_access_the_resource() {
    assertThat(subject.canUserAccessResource("Mallory")).isFalse();
}

@Test
public void mallory_can_be_added_to_the_allowed_users() {
    subject.getAllowedUsers().set(0, "Mallory");

    assertThat(subject.canUserAccessResource("Mallory")).isTrue();
}
{% endhighlight %}

Ok. Nevermind. Instead of learning how we can alleviate the above why don't we use more modern languages which might bring us some immutability. Like [Kotlin](https://kotlinlang.org/).

The Java implementation looks as follows in Kotlin

{% highlight kotlin %}
val allowedUsers = listOf("Alice", "Bob", "Charlie")

fun canUserAccessResource(username: String): Boolean {
    return this.allowedUsers.contains(username)
}
{% endhighlight %}

The docs on [listOf](https://kotlinlang.org/api/latest/jvm/stdlib/kotlin.collections/list-of.html)
state

> Returns a new read-only list of given elements.

So, is the security issue fixed?

We verify it with [kotlinc](https://kotlinlang.org/docs/tutorials/command-line.html)

{% highlight bash %}
>>> val authorizedUsers = listOf("Alice", "Bob", "Charlie")
>>> authorizedUsers
[Alice, Bob, Charlie]
val mp = list as MutableList<Int>
mp[2] = 5 // changes both list and mp
{% endhighlight %}

Attempts along the lines of

{% highlight bash %}
authorizedUsers[2] = "Mallory"
{% endhighlight %}

or

{% highlight bash %}
authorizedUsers = listOf("Mallory")
{% endhighlight %}

will fail.

There is neither a `set` method to provide array access or the possibility to reassign `val`

Nevertheless, we can cast it to a [MutableList](https://kotlinlang.org/api/latest/jvm/stdlib/kotlin.collections/-mutable-list/index.html) and do the following

{% highlight bash %}
>>> val unauthorizedUsers = authorizedUsers as MutableList<String>
>>> unauthorizedUsers[1] = "Mallory"
>>> unauthorizedUsers
[Alice, Mallory, Charlie]
>>> authorizedUsers
[Alice, Mallory, Charlie]
{% endhighlight %}

Oh snap. The actual object can be changed by another reference.

In defense of Kotlin. It's stressed quite [often](https://www.youtube.com/watch?v=Uizh2WlJtnk&feature=youtu.be&t=2470) how the wording `read-only` is used instead of `immutability`.

Although the wording `MutableList` might suggest using `List` would be immutable.

On with the journey.

Let's crack open a Haskell REPL ([stack](https://docs.haskellstack.org/en/stable/README/))

{% highlight bash %}
λ> let authorizedUsers = ["Alice", "Bob", "Charlie"]
λ> authorizedUsers
["Alice","Bob","Charlie"]
λ> authorizedUsers ++ ["Mallory"]
["Alice","Bob","Charlie","Mallory"]
λ> authorizedUsers
["Alice","Bob","Charlie"]
{% endhighlight %}

Data is immutable in Haskell. We do not mutate the existing list but build a new list from applying the function.
Haskell lends us a hand at avoiding the issue.

Why does all the above matter? It's about predictability. Would a senior programmer recognize the bug in the Java example? Quite likely. Would a junior or a senior with sleep deprivation on a deadline?
Would you want to keep in mind how every other part of the codebase is able to modify the allowed users? I guess the answer is no.

Of course we can fix the issue with Java by simply copying the list in the getter

{% highlight java %}
public List<String> getAllowedUsers() {
    return new ArrayList<>(allowedUsers);
}
{% endhighlight %}

Although that is something we would have to remember all the time.

Would someone starting out with Kotlin realize the difference between `read-only` and `immutability` before stumbling upon it in the docs or when encountering a bug?

Seems how the simplest approach to getting the issues above out of the way is by using immutability by default.

Code examples can be found on [GitHub](https://github.com/axelhodler/non-immutabbility-samples)
