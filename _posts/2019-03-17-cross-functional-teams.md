---
layout: post
title: "Cross Functional Teams and People"
date:   2019-03-17 19:21:24
description: ""
category:
tags: ["Software Development", "Cross Functional Teams", "Agile", "People Management", "Teamwork"]
---

<img src="https://www.dropbox.com/s/kefgltq4c5iwgc3/cross_function_header.jpeg?raw=1" alt="preview_picture" />

We have the frontend folks, including app developers, of course the ones working on the server-side, our customers, or at least the people representing the customer, surely our domain experts and obviously our UX designers.

All of these folks are united in one team. An agile team. We’re lucky. Two pizzas squelch our hunger. We design, develop and deploy the software. End to End. We build it, we run it. We are a cross functional team.

We have _[all competencies needed to accomplish the work without depending on others not part of the team](https://www.scrumguides.org/scrum-guide.html#team)_.

In the spirit of [Kaizen](https://en.wikipedia.org/wiki/Kaizen) we want to improve. Our former bottlenecks have moved.

Instead of waiting for the external design agency to deliver the css files and the icons we wait for Christina. Christina is currently speaking at a conference in Barcelona. Good for her. A blocker for team.

Our iOS app needs an update to properly deal with the new devices. Unfortunately our iOS developer quit last week to work for a startup. Allan our Android guy might be able to fix the issue if he was not hating the whole Apple ecosystem with a passion.

We would love to ship the new version, including a bug fix, to the customer. Today. Much to our chagrin Jeff, the only one currently capable of understanding our AWS CloudFormation setup, called in sick this morning.

Naturally it’s not the first time this has happened. In a previous retrospective we went through the issue of having a lack of specific know-how and decided every job should be doable by multiple people. Jeff had to explain the AWS setup to Allan and Christina gave Joe an introduction to Sketch.

Now things are fine until one is sick and the other on a well deserved time-out on the Bahamas.

> "Okay..." you might say. "Seems you are suggesting everyone in the team should be able to cover for everyone else in the team?"

No, although it would be great if that were the case. What you could do is nudge people, if they are willing to learn new things, into the general direction. As one of our colleagues stated:

> You don't need to do a four-week iOS workshop to change the gradient on an image or improve the text on a button

We can even add tasks such as displaying a notification or consuming and displaying another field from a REST API to that list.

Being a bit more cynical, programming is just if-statements. Or pattern matching for the more functionally inclined. And last but not least Google and Stack Overflow.

There's an often observable divide between the Frontend and the Backend. Between the heroes who make sure to not put the memory of the older iPhones to its knees and to make sure the hapless users of Internet Explorer get at least some use out of our WebApp. On the other hand we have the folks on the backend. Working in _proper_ programming languages they make sure to integrate that finicky third party API and to not have the user wait ages for a simple database query.

Stories, Tasks and Bugs are then categorised according to their part in the system. They get labels such as _Android, iOS or Backend_. Sometimes the clients have to wait for changes to the API for a new feature. When they finally get to use the API and something does not fit the API creator might already be working on other things. They now have to switch back to the old task. Additionally theres the whole blame game of which part is to blame for a bug or which part is always last to finish a feature. A whole grab bag of discussions. Not knowing the intricacies of the other system, around _"It can't be that hard to display that value?"_ or _"Why isn't this logic part of the backend?"_. No one might not know the constraints the other part is coping with.

Let's get the different parts in the team closer together! But who should be in charge to facilitate the knowledge sharing then?

The team. After all it's supposed to be self organising. If you need to go to a manager to ask for a new iOS developer it might take a while. What one can do right now is to get the current iOS developer to enable someone else currently in the team.

Next time a new value has to be displayed in one of the clients sit together with one of the specialists of the client and pair with him or her. Even better if it’s done on the persons machine who did not yet work on the client. As a bonus we can make sure the _Setup_ documentation for IDE, tooling and dependencies is still up to date.

For starters, make sure it's a small task. Not a huge new feature which would involve discussions around architecture. We also do not need to explain the whole project setup and why things are the way they are. First we navigate to the file to change, implement the test and implement the feature. That should be enough for the start. The person new to the code has already learned a lot going through that simple change and we get some feedback on how easy it is to onboard someone new to the codebase. Next time he might be able to do the change by himself.

Knowledge sharing in our team is not constrained to developers only. If a designer might want to change the colour of a button you can show her the file to change and how to validate the change has worked. Next time we might even discover and implement the design together right away. Who knows?

Another issue we alleviate is developer boredom. Instead of introducing a new technology for the sake of [resume driven development](https://rdd.io/), which ultimately does not help the project itself, the bored developer can explore technologies already part of the project. There should be enough of them. Instead of replacing RabbitMQ with Kafka the backend developer could learn some Angular, a technology already used in the project. Rather than migrating the Angular app to React our JavaScript developer might be introduced to Spring Boot and Kotlin.

Of course there might be downsides and challenges. A developer might be very territorial or just trying to protect his or her job but then we end up at [people problems](https://blog.codinghorror.com/no-matter-what-they-tell-you-its-a-people-problem), which is another topic in itself.

Or what if management might not want to indirectly pay the iOS specialist to learn Kotlin? But then, why would management care how you organise your team as long as you keep delivering value?

Article has been cross-posted on [Medium](https://medium.com/@axelhodler/cross-functional-teams-and-cross-functional-people-e650c46907e1).
