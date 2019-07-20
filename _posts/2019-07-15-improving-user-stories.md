---
layout: post
title: "Improving User Stories"
date:   2019-07-15 17:21:22
description: ""
category:
tags: ["Data Visualization", "Data Analysis", "R", "McDonalds", "Maps"]
---

<img src="https://www.dropbox.com/s/fjedevsjeqh95wl/user_stories_header.jpeg?raw=1" alt="preview_picture" />

Everyone involved in modern-day software development will have stumbled upon a piece of text with the following structure

{% highlight text %}
As a user
I want to have a blue logout button in my profile
So that I can log out
{% endhighlight %}

The above is supposed to be a User Story. It’s an attempt to describe the functionality, the what, and the desired benefit, the why, for a user. After turning the User Story into an implementation the user value of the product, for example an app, should be higher than it was before. After all increasing the user value, and thus revenue in the future or now, is the goal of almost all products.

But is the User Story above a _proper_ User Story? Does it not have all the necessary semantics? Is there even such as thing as a _proper_ User Story?

This article is an attempt to work with these questions.

Let’s start with evaluating th _"Why?"_ part of the User Story? The reason for having the change in the first place. To give some context let’s suggest the app at hand is a note taking application from which the user can’t currently log out. The desired benefit is stated as

{% highlight text %}
So that I can log out
{% endhighlight %}

It’s always helpful to as _"Why?"_ few times. Why does the user need to log out? Is it to switch the account? Is the user scared someone else is going to use the application afterwards and private notes are leaked? Does the user even want to log in at all? Don’t we all love it if an app forces us to register or log in without telling us the reason? Or do we need it because after all most apps have logout buttons and we certainly don’t want to be the outlier?

Questions over questions.

As a result the asking of _"Why?"_ already helps us to uncover, or to at least to get closer to, the real benefit to the user. For the sake of argument we can go with the need to switch the accounts. Maybe the user shares the device with others or has an account for business related notes and an account for private notes.

The part describing the desired benefit could be modified into

{% highlight text %}
So that I am able to switch my account
{% endhighlight %}

Disregarding further changes for a second the User Story now reads as

{% highlight text %}
As a user
I want to have a blue logout button in my profile
So that I am able to switch my account
{% endhighlight %}

We have changed the User Story to the better. It contains more truth than before. The user does not want to log out. The user wants to change the account. To log out and to log in again is one possibility to achieve it.

On with the _"What?"_ part

{% highlight text %}
I want to have a blue logout button in my profile
{% endhighlight %}

Again we are going to ask a few _"Why?"_ questions. Why does the Logout button have to be blue? That’s a design concern. Would it not be of value to the user if it was grey or purple? Why does it have to be in a specific location of our app, the user profile? More importantly: Why do we need a Logout Button at all if the desired benefit is to switch accounts?

As we might have learned in our conversation the user wants to switch the account to both have a private account and an account for business related notes.

Having that knowledge we can get creative. Might a selection of accounts and the possibilities to add other accounts, a function we will find in most Email clients, be a more suitable solution for the user? If the answer is yes the User Story evolves into

{% highlight text %}
As a user
I want to be able to switch my account
So that I am able to switch my account
{% endhighlight %}

The above will make most folks chuckle. Justifiably. We can avoid it by stating our discovered benefit. The division of a private and a business related account and its respective notes.

{% highlight text %}
As a user
I want to be able to switch my account
So that I can separate private and business related notes
{% endhighlight %}

It states the benefit to the user and the functionality to achieve the benefit. We’re almost done.

Let’s take a look at the part we did not yet touch

{% highlight text %}
As a user
{% endhighlight %}

Sadly it does not tell us a lot. What type of user are we talking about? A premium user, an admin, a freemium user, a non english speaking user or an unregistered guest?

Some projects are using [personas](https://en.wikipedia.org/wiki/Persona_(user_experience)). A fictional character to represent a user type. Consider we already have a persona which might use our app both for private and business related notes. The personas name is Meredith.

{% highlight text %}
As Meredith
I want to be able to switch my account
So that I can separate private and business related notes
{% endhighlight %}

If we compare the User Story with the one we started out with

{% highlight text %}
As a user
I want to have a blue logout button in my profile
So that I can log out
{% endhighlight %}

A lot has changed. By asking a few questions in a conversation and some creativity.

But why did we start out with the User Story in the beginning? Why does a User Story often look like this? Mostly because what has been a specification in the past is now hidden in a User Story and we are labeled more _"agile"_ because we are writing user stories. Even the wikipedia article on [User story](https://en.wikipedia.org/wiki/User_story) mentions the issue in the opening paragraph.

We do not have to go with User Stories to describe the features of software. Use whatever works best with your team. But if we go into lengths writing the _As a, I want, So that_ then we should avoid doing it half-hearted.

Finally we should remember that in the example above the user wanted to switch accounts to have a separation between private and business related notes. It’s necessary to keep in mind creating the logout functionality is still a valid, though certainly not the best, approach to achieve the above. But if the team states having the account switcher is three times as much work as the logout button the team might decide to go with the logout button after all. Nevertheless we should not constrain the solution by stating the desired implementation right away.

Maybe our account switcher is not the greatest solution for the user either? Maybe there is a better solution hiding in plain sight? Could we not get the same benefit from using one account with different types of notes to avoid blending the two?

These alternative solutions appear when we actually focus on the desired benefit to the user and allow space for creativity instead of wrapping requirement documents into a User Story.

Even if we don’t improve anything at first, we have talked about it and hopefully improved our understanding of the domain.

Article has been cross-posted on [Medium](https://medium.com/@axelhodler/improving-user-stories-e6d0e8af65eb).
