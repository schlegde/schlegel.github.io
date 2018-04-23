---
layout: post
title: "SoCraTes Canaries 2018"
date:   2018-04-16 12:21:22
description: ""
category:
tags: []
---

I have spent the last few days on [Gran Canaria](https://en.wikipedia.org/wiki/Gran_Canaria) participating in the wonderful 2018 edition of [SoCraTes Canaries 2018](http://socracan.com/).

The following post is a recollection of some thoughts and lessons learned throughout the conference.

<img src="https://www.dropbox.com/s/qjrioedc2u0b8ju/event_storming.jpg?raw=1" alt="event storming" />

## Friday

After a quick icebreaker these were the sessions of the day

<blockquote class="twitter-tweet" data-lang="en"><p lang="en" dir="ltr">OpenSpace panel. Really excited with the proposals! <a href="https://t.co/KRu3VpS63v">pic.twitter.com/KRu3VpS63v</a></p>&mdash; Socracan (SoCraTes Canaries) (@socracan) <a href="https://twitter.com/socracan/status/984732710341103616?ref_src=twsrc%5Etfw">April 13, 2018</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

I participated in the following ones

### Why do products succeed or fail?

To have a definition of success we defined it as

> customer got the value she expected in the expected amount of time

It all boiled down to communication and trust between developers, the business and the customer. Also to having a small scope (MVP) by doing the most important thing first and increment from there. By rushing to get a huge scope done in time it all leads to non extendable code and bugs.

### CI/CD

A fruitful talk on the beach about how different teams handle their CI/CD pipelines with multiple deployments. How they deal with configuration, adding configuration to the apps during the build or by using config servers in a microservice environment.

### API Monitoring

The session started with a problem description. An app gets content, images and text, from a third party content server. As it happens some images or text might be missing. How would we get notified of missing content to avoid the issue of a customer viewing incomplete infos? After a quick solution of permanentely polling the content and validating it, sending notifications if something is missing, we got to the point of alleviating the problem altogether.

By putting a quality gateway between the app and the content server we can avoid having the customer experience incomplete content. The quality gateway will completely reject incomplete content, sending a notification to someone who can resolve the issue of missing content.

### Event Storming

With the best background imaginable, we have already seen the picture above, we did an event storming session for an auction house.
One of the goals of event storming is using the same language between business and development, called _Ubiquitous Language_. Thus actions such as `EndAuction`, triggering events such as `AuctionEnded` are identified and interconnected. In the end one can identify the aggregates, e.g. Auction, Delivery, Payment to further structure the software into different services and classes.

### Waste

A discussion on what we regard as waste during software development and how to decrease wasted time. Examples were working with Pull-Requests (PR), especially with juniors that are left working for a while on a PR to then tell them how to do it correctly instead of pairing with them in the first place. This does not only apply to juniors. Every seasoned developer probably had some moments were he spent quite a while on a non trivial solution just to see it discarded when during the code review of the PR a colleague came up with a simpler or more elegant solution.

Another big topic were statistics such as the velocity of the team or burn-down charts. They can easily be gamed and tell nothing about whether value was delivered to the customer. All these were the ones which found almost unanimous agreement. Differences started to emerge as soon as branching workflows were called waste when comparing them to trunk based development.

### Nature of learning

An overview of how people learn. Some might be visual learners. They easily learn from symbols, arrows and shapes on a whiteboard, while others learn better from reading plain words. See [Neil Fleming's VAK/VARK model](https://en.wikipedia.org/wiki/Learning_styles#Neil_Fleming's_VAK/VARK_model) for an entry point into the topic.

Further examples were the use of speed-reading when we want to quickly extract knowledge instead of savoring every word of the author. The session went into the necessity of applying the learned knowledge and to refresh knowledge from the past. An example would be getting back to a programming language which the developer did not use for a while but was very proficient with back in the past.

### How we all work

We ended the official part of the day at a bar telling stories of how we work. The high points, as well as trials and tribulations, of some consulting gigs or when working on product development. How folks deal with remote teams or whether techniques such as Scrum or TDD are used. Quite interesting anecdotes. One of them was how a lot of money was saved because the customer was asked when the software should be up and running. The answer was from 9 to 5 from Monday to Friday. Thus one would not need to invest a lot in monitoring or techniques such as [Blue Green Deployment](https://martinfowler.com/bliki/BlueGreenDeployment.html). One had a fixed time window when to update and if there would ever be a memory leak one could just restart the server every night without the customer noticing or caring.

## Saturday

After a retrospective for the day before these were the sessions that emerged

<blockquote class="twitter-tweet" data-lang="en"><p lang="en" dir="ltr">Ready to talk about CDC testing and continue learning from others at the <a href="https://twitter.com/hashtag/socracan2018?src=hash&amp;ref_src=twsrc%5Etfw">#socracan2018</a> second day 🚀 <a href="https://t.co/ewmiLiKLRF">pic.twitter.com/ewmiLiKLRF</a></p>&mdash; Paulo Clavijo (@pclavijo) <a href="https://twitter.com/pclavijo/status/985109174483898369?ref_src=twsrc%5Etfw">April 14, 2018</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

### Consumer Driven Contract Testing

A topic that is heavily used in one of my current projects. One quick way of describing it could be _TDD for microservices_. The API consumers (e.g. an app or another microservice) write contracts on how he requires the API to behave, e.g. which fields of a response he uses. On the provider side (a service) there will be a test which makes sure the contract is not violated. Thus if the provider removes a field from a response, which is not mentioned in any contract, all tests will still pass. Thus the field was save to be removed. No consumer was using or expecting it.

It was great to see how other teams use the technique. The provided examples were using [Pact](https://docs.pact.io/) where the consumers write the contracts in the programming language of their choice. I use [Spring Cloud Contract](https://cloud.spring.io/spring-cloud-contract/) where the consumers write the contracts in a [DSL](https://en.wikipedia.org/wiki/Domain-specific_language). One of the arguments for Spring Cloud Contract was the missing support for messaging in Pact, though Pact will also support messaging in a future version.

## Monitoring with Prometheus and Grafana

[Prometheus](https://prometheus.io/) is a monitoring solution which gathers and provides metrics, e.g. requests, memory / CPU, page load, which can then be displayed on a dashboard via [Grafana](https://grafana.com/). In the session both tools were set up live on a fresh [DigitalOcean](https://www.digitalocean.com/) instance.

## Integration Tests for third party API

The session I held went through some ways of how we make sure to correctly integrate third party API. Third party API was described as an API we are not able to change or to fix if something misbehaves.

An example would be the [Google Maps APIs](https://developers.google.com/maps). Google decides how the API behaves and whether it exists.

I was using _Consumer Driven Contract Testing_ to make sure there is no mismatch between structure of the actual response and the expected response from the API and a way to recognize if the API changes.

The contents of the talk will be provided in a future blog post.

### Gilded Rose Kata

It's a terrific example of learning where to start understanding and refactoring code. Definitely a hard Kata. We started using JavaScript and in the end went through solutions in other languages such as F# and Java on GitHub.

A walkthrough of the Kata in Ruby by Sandi Metz, which I highly recommend, can be found on [YouTube](https://www.youtube.com/watch?v=8bZh5LMaSmE)

### Connascence
What followed was a presentation of the Kata [Red, green ... what now?!](https://silkandspinach.net/2015/05/20/red-green-what-now/) by Kevin Rutherford. [Connascence](http://connascence.io/) is a software quality metric that measures coupling between entities. If a method accepts two `String` types then we have `Connascence of Position`, thus the order of the arguments is important.

If we have `method(String name, String mail)` we might accidentially switch the order and a consumer could supply the mail as the first argument instead of the name. The solution would be to pass an Object such as `User` or use different domain types such as `Mail` and `Name`.

I've already heard of the term in an awesome [talk by the late Jim Weirich](https://www.youtube.com/watch?v=22vYwcfQnk8) a while ago and the session served as a nice refresher on the topic.

### Discussion on Flow

A discussion I wanted to have at the beach. Since Uncle Bob regards it as [counterproductive](https://github.com/holman/ama/issues/186) and Kata constraints such as

> reset back to the last commit if you did not commit for 2 minutes

paint a picture of how getting into a flow state is not helpful and discussion might be warranted.

You might also call it _being in the zone_ or _the tunnel_. Some participants have never experienced flow and others avoid to enter it during work hours. Modern approaches such as Pair- or Mob-Programming make getting into the zone impossible.

We discussed how sitting in the corner with your headphones on, not wanting to be disturbed by anyone, is probably bad since it squelches conversation and makes other developers or the business afraid to raise questions. Additionally, if someone needs to have a ramp up time of 15min to get back into the zone or cannot be disturbed while holding an algorithm in her head it's a sign that the code is way too complicated and needs to be broken down into smaller parts.

We jokingly concluded the discussion as somewhat boring since the participants of the conference are all living in a bubble and thus all view being in the zone as counterproductive.

### TDD for kids

We can write formulas for Google Spreadsheets in JavaScript! (See `Tools -> Script editor`). The session showed how it's a great way to teach TDD to your kids (or to managers who definitely know spreadsheets). Thus with an `if true` check and conditional formatting we can do TDD. Also a reminder on how the only thing necessary to do testing is an a way to build an `assert true` statement.

To to get you started with the [Roman numerals Kata](http://codingdojo.org/kata/RomanNumerals/) have a look [here](https://docs.google.com/spreadsheets/d/1_3f1iDn-Jwp1Q-a5yMPnbWe6glq2kuIU-ltjvNjCRrU/edit?usp=sharing). One of the best sessions.

## Conclusion

The retrospective at the end concluded everyone had a blast. The only negative point multiple participants mentioned was the use of plastic and paper cups instead of reusable ones but that one can surely be remedied.

A big thank you to all the participants. I'm definitely looking forward to the 2019 edition.

<blockquote class="twitter-tweet tw-align-center" data-lang="en-gb"><p lang="en" dir="ltr">Final retrospective at the beach. Such amazing weather and place. Thanks everybody for creating an amazing experience every year. See you again in 2019! <a href="https://t.co/PXm7uVaRu0">pic.twitter.com/PXm7uVaRu0</a></p>&mdash; Socracan (SoCraTes Canaries) (@socracan) <a href="https://twitter.com/socracan/status/985240938099433472?ref_src=twsrc%5Etfw">14 April 2018</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

