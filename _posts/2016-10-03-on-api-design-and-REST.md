---
layout: post
title: "On API Design and REST"
date:   2016-10-03 12:41:33
description: ""
category:
tags: []
---

Say we have a Resource called `books`. The API Developer gets the task of providing the functionality

* Purchase a book

Assume the calls to `Create a book`, `Update a book`, `Delete a book` and `Get information about a book` are already present via the respective `POST`, `PUT` or `PATCH`, `DELETE` and `GET` actions.

The server side probably contains a method such as:

{% highlight java %}
bookStore.purchase(bookId)
{% endhighlight %}

A quick win for the API Developer, without changing the existing endpoints and thus risking a breakage, would be to add a new REST endpoint that operates on the book resource with the following structure:

{% highlight java %}
@PUT
/books/{bookId}/purchase
{% endhighlight %}

The new endpoint can internally delegate the purchase to the `purchase` method in `bookStore`. The task is completed and all seems well.

Now the client, using the library [Backbone.js](http://backbonejs.org/) will add this functionality to the front end. In Backbone a resource offers the following default operations to inter operate with a REST API: `fetch()` for a `GET` request, `save()` to create via `POST` request or update via `PUT` request and `destroy()` to `DELETE`.

To achieve the purchase she will have to break out of the simple `fetch()`, `save()`, `destroy()` flow and create the HTTP-Request via [Backbone.ajax](http://backbonejs.org/#Sync-ajax)

{% highlight javascript %}
Backbone.ajax({
  method: 'PUT',
  url: '/books/' + this.get('id') + '/purchase'
});
{% endhighlight %}

It seems odd to use the custom Ajax function and to let the client create the URI via string concatenation. That fact alone is trying to tell us something is not right. We learn this without actually reading more than the chapter headers of [Fieldings Dissertation](http://www.ics.uci.edu/~fielding/pubs/dissertation/rest_arch_style.htm), where REST is defined as _Representational State Transfer_. No state is transferred in the ajax call above, it does not even need a request body, the URI is enough to achieve the desired outcome.

The above is not limited to Backbone.js. Similar issues arise when using [Ember.js](http://emberjs.com/) together with [Ember Data](https://github.com/emberjs/data) which follows [JSON API](http://jsonapi.org/) and makes it hard to break out of the REST model.

Nevertheless, the purchase functionality is completed. Customers can purchase books. They are happy.

A few days later we get a feature request to show to the user if he already owns the book he is currently looking at in the online store. The book resource is extended with a new property.

{% highlight javascript %}
{
  ...
  purchased: true
  ...
}
{% endhighlight %}

If the `purchased` flag is true, the user sees a message similar to

> You already own this book.

At this point the person working on the client side starts to wonder why he had to use the `/purchase` endpoint in the first place. As it would have been easier for her to use:

{% highlight javascript %}
book.set('purchased', true);
book.save();
{% endhighlight %}

There was no need for the extra `/purchase` endpoint. With the linking of an endpoint to an action the API will continuously grow. Say our bookstore will offer a book reviewer to approve or reject books. Which would lead to `/approve` or `/reject` actions and therefore new endpoints. A better way would be to let the client set the flags and save (`POST`, `PUT`, `PATCH`) the entity as explained above.

[The following answer on Stack Overflow](http://programmers.stackexchange.com/a/261647) does a good job of summing it up:

> The client just says "This is the state you should be in now" and the server figures out how to achieve that. It might be a simple flip in a database. It might require thousands of actions. The client doesn't care, and doesn't have to know.

Hopefully this blog post encourages collaboration between the developers working on the server side and the ones working on the client side before creating the actual API.
