---
layout: post
title: "Composition over Inheritance"
date:   2016-01-30 13:36:33
description: ""
category:
tags: []
---
You probably have heard of the principle [Composition over Inheritance](https://en.wikipedia.org/wiki/Composition_over_inheritance). Recently I stumbled upon an awesome talk at [RailsConf 2015](https://www.youtube.com/watch?v=OMPfEXIlTVE) by [Sandi Metz](https://twitter.com/sandimetz) where in the second part she showcases the principle. I strongly suggest watching it.

In the first half of the talk she explains why we do not need an if statement in OOP, since before starting with Ruby she used [Smalltalk](https://en.wikipedia.org/wiki/Smalltalk) which does not even provide an if statement. If like me you have waded through methods having 50 and more nested if/else statements, not having access to an if statement sure looks like a good idea.

During the course of the example we are shown how to tackle evolving feature requests for a simple program without intoducing any if statements in the solution. During her talk the design moves towards inheritance only to change to the flexible composition approach later on. I wondered if the same would have happened if we were test driving the design. After all, doesn't [TDD lead to better design?](https://www.youtube.com/watch?v=ty3p5VDcoOI)

# The House That Jack Built

If you have not watched Sandi's talk here is the gist of it. The goal of the program is to recite [This Is the House That Jack Built](https://en.wikipedia.org/wiki/This_Is_the_House_That_Jack_Built) a traditional rhyme for young children in Britain.

It starts with

{% highlight bash %}
This is the house that Jack built.
{% endhighlight %}

And will then add more details after every repetition

{% highlight bash %}
This is the malt that lay in the house that Jack built.
{% endhighlight %}

After adding a few more details it will look like this

{% highlight bash %}
This is the horse and the hound and the horn
That belonged to the farmer sowing his corn
That kept the rooster that crowed in the morn
[...]
That tossed the dog that worried the cat
That killed the rat that ate the malt
That lay in the house that Jack built.
{% endhighlight %}

For our implementation we shorten the poem to the following four verses for brevity.

{% highlight bash %}
This the dog that worried
the rat that ate
the malt that lay in
the house that Jack built
{% endhighlight %}

The first test is easy, were only comparing strings

{% highlight java %}
public class JacksHouseShould {
  @Test
  public void be_recitable() {
    JacksHouse house = new JacksHouse();

    assertThat(house.recite(),
            is("This is the dog that worried " +
            "the rat that ate the malt that lay in " +
            "the house that Jack built"));
  }
}
{% endhighlight %}

Which leads to the implementation

{% highlight java %}
public class JacksHouse {
  public String recite() {
    return "This is the dog that worried " +
            "the rat that ate the malt that lay in " +
            "the house that Jack built";
  }
}
{% endhighlight %}

The poem can be recited. Everything is awesome. Until we get a feature request. The poem should be recitable in a random order. Which could lead to the following output


Let's find a way to get the sentences for each repetition

## The data would probably be in a database or a filesystem,
boundaries boundaries boundaries

# How are we going to test random?
We don't we have to inject already randomized data.
We introduce a boundary. Were not going to test what we dont own
{% highlight java %}
private List<String> parts(int lineId) {
  int dataSize = data().size();
  return data().subList(dataSize - lineId, dataSize);
}
{% endhighlight %}


`parts(2)` will provide `[the malt that lay in, the house that Jack built]`

Now we should a space between each piece

{% highlight java %}
private String phrase(int lineId) {
  return parts(lineId).stream().collect(Collectors.joining(" "));
}
{% endhighlight %}

Of course the poem should start with `This is` so we add

{% highlight java %}
private String line(int lineId) {
  return String.format("This is %s \n", phrase(lineId));
}
{% endhighlight %}

To recite the poem

{% highlight java %}
public void recite() {
  IntStream.range(1, data().size())
    .forEach(count ->
      System.out.println(line(count)));
}
{% endhighlight %}

Now these methods are put into the `House` class and were fine. Until we get a feature request. Instead of using the general order we need to randomize the Strings so we can have the output

{% highlight bash %}
This is the farmer sowing his corn that kept
the rat that ate
the malt that lay in
the dog that worried
[...]
{% endhighlight %}

The quickest way with inheritance would be to create `RandomHouse extends House`. We need to change the modifier in `data()` to `protected` so we can override it in `RandomHouse`. I had to introduce an if case to offer a quick way to not shuffle the array on every call to `data()` without using an extra cache. We're now already at a point where i start to dislike the design. Thinking I should inject the data so I don't have to work with the _cached_ return value.

{% highlight java %}
public class RandomHouse extends House {

  List<String> shuffledData;

  @Override
  protected List<String> data() {
    if (shuffledData == null) {
      shuffledData = super.data();
      Collections.shuffle(shuffledData);
    }
    return shuffledData;
  }
}
{% endhighlight %}

Everything works as expected and we get a new feature request. We want an `EchoHouse` to repeat every line once

{% highlight bash %}
This is the malt that lay in the malt that lay in
the house that Jack built the house that Jack built
{% endhighlight %}

We change the `parts` method to `protected` and create `EchoHouse` follows

{% highlight java %}
public class EchoHouse extends House {

  @Override
  public List<String> parts(int lineId) {
    List<String> echoedStrings = new ArrayList<>();

    super.parts(lineId).stream()
            .forEach(item -> {
              echoedStrings.addAll(Arrays.asList(item, item));
            });

    return echoedStrings;
  }

}
{% endhighlight %}

Everything runs smooth until we get the feature request to build a `RandomEchoHouse`. Since Java does not have multiple inheritance we're stuck. How do we solve this without duplicating code?

## Composition

[Sandi Metz](https://twitter.com/sandimetz) described it as

> Inject an object to play the role of the thing that varies

What does _vary_ in our houses?

First, the order of the data. There's a default order and a random order. Second, the using formatting. We have default formatting and the echo formatting.

Lets create the interface
