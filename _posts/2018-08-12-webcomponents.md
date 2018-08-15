---
layout: post
title: "Web components"
date:   2018-08-12
description: ""
category:
tags: []
---

Since moving from plain server side rendering to the newest JavaScript tools at the end of 2014 I was able to use EmberJS, AngularJS, jQuery, Backbone.js and the successor of AngularJS which is now referred to as _just_ Angular.

One of the AngularJS projects might be rewritten in Angular and one of the jQuery projects is being rewritten in Angular. Probably half of the developers are wishing they were using React and a tenth wishing they were using [Elm](https://elm-lang.org).

Without discrediting any of these frameworks, they are used to display the constant change happening in the JavaScript ecosystem.

Maybe a way of avoiding _costly_ rewrites would be to have a look at [web components](https://www.webcomponents.org/introduction). 

Web components are not tied to any framework. They make use of HTML, CSS and JavaScript. So whether we use Angular or Vue.js or anything else we would be able to reuse our web components without any specific library just by using the native features of our browsers.

For our example we'll be using a modified and stripped down example by [Wolfram Kriesing](https://twitter.com/wolframkriesing/status/1026075696748220417), who did a terrific job explaining the concept at [BusConf 2018](http://www.bus-conf.org/).

Our goal is to display a `h1` tag with an icon to the left. The icon should produce a link to the heading in our browsers search bar. The result is similar to what we see when we hover on any of the headings (take `Setup` for example) in [a README.md file](https://github.com/axelhodler/hodler.github.io/blob/master/README.md) on GitHub.

We can preview the result of what we're going to create on [GitHub Pages](https://github.com/axelhodler/webcomponent)

Using a web component makes sense because we will be, similar to the usual README, use the element multiple times.

Our web component will have two main parts. The markup and the behavior. The markup can be divided into style and structure.

{% highlight html %}
<style>
    a {
        visibility: hidden;
        text-decoration:none;
    }

    h1:hover a {
        visibility: visible;
    }
</style>

<h1>
    <a id="link">🔗</a>
    <span id="title"></span>
</h1>
{% endhighlight %}

Via css we're specifying hidden visibility on anchor tags (`a`) and make them visible when hovering over a `h1` tag.

We make use of [Shadow DOM](https://developers.google.com/web/fundamentals/web-components/shadowdom). Shadow DOM allows us to encapsulate, or rather _shadow_, the markup structure, style and behavior of a component hidden from the rest of the page. Thus styles applied to the shadowed component won't leak out to the page and page styles won't bleed in. As a result the styles above will not be applied to `h1` and `a` tags outside of our component.

Additionally name conflicts are harder since `document.querySelector()` won't return nodes in the components shadow DOM.

Our goal is to use the following in our `index.html` file.

{% highlight html %}
<ah-h1 title="My title"></ah-h1>
{% endhighlight %}

Using an [ES6 class expression](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/class) we define the behavior of our web component.

{% highlight javascript %}
class EasilyLinkableH1 extends HTMLElement {
  constructor() {
    super()
    let templateContent = template.content
    const shadowRoot = this.attachShadow({mode: 'open'})
      .appendChild(templateContent.cloneNode(true))
  }

  connectedCallback() {
    const title = this.getAttribute("title")
    this.setAttribute('id', title)
    this.shadowRoot.querySelector('#link')
      .setAttribute('href', `#${title}`)
    this.shadowRoot.querySelector('#title').innerHTML = title
  }
}
{% endhighlight %}

We define our `shadowRoot` in the constructor and set our `connectedCallback()`, which is called after the element is attached to the DOM. The `id` of the component is set to use the `title` attribute.

{% highlight javascript %}
const title = this.getAttribute("title")
this.setAttribute('id', title)
{% endhighlight %}

The value of `id` will be `My title` as defined in the markup above.

Then we make sure the anchor tag points to the title and the heading uses the title

{% highlight javascript %}
this.shadowRoot.querySelector('#link')
  .setAttribute('href', `#${title}`)
this.shadowRoot.querySelector('#title')
  .innerHTML = title
{% endhighlight %}

Finally we define our custom tag to enable it.

{% highlight javascript %}
customElements.define('ah-h1', EasilyLinkableH1)
{% endhighlight %}

We're now able to use it in our html page. See [index.html](https://github.com/axelhodler/webcomponent/blob/master/index.html).

{% highlight html %}
<ah-h1 title="Getting Started"></ah-h1>
{% endhighlight %}

As a nice addition there are `slots`. A slot allows us to define placeholders in the template. These placeholders can be filled with any markup and are used to display a description after the heading in our example. If we don't provide a description we use the text `Default`.

{% highlight html %}
<div>
    <slot name="description">Default Text</slot>
</div>
{% endhighlight %}

To show it's usage

{% highlight html %}
<ah-h1 title="License">
  <span slot="description">
    A description of the license
  </span>
</ah-h1>
{% endhighlight %}

### Testing

We can grab [QUnit](https://qunitjs.com/) and start testing. QUnit might seem like an "outdated" choice but it's, at the time of this writing, still used by [jQuery](https://jquery.com/) and the testing guide of [ember](https://guides.emberjs.com/release/testing/). It should be a stable choice for the future.

A simple test suite, verifying the two main properties of the web component might start as follows.

{% highlight javascript %}
let component

QUnit.testStart(() => {
  component = document.createElement('ah-h1')
})

QUnit.testDone(() => {
  document.body.removeChild(component)
})
{% endhighlight %}

In the `testStart` function we create the component and make sure to remove it from the `body` in the `testDone` function.

The following tests will make sure the `title` is displayed.

{% highlight javascript %}
QUnit.test("component displays title attribute", assert => {
  const title = 'My Title'
  component.setAttribute('title', title)
  document.body.appendChild(component)

  const actualTitle = document.getElementById('My Title').shadowRoot
    .querySelector('#title').innerText
  assert.equal(actualTitle, title)
})
{% endhighlight %}

The next one makes sure we have a direct link to the heading.

{% highlight javascript %}
QUnit.test("component link anchors on title", assert => {
  const id = 'id'
  component.setAttribute('title', id)
  document.body.appendChild(component)

  const ref = document.getElementById(id).shadowRoot
    .querySelector('#link').getAttribute('href')
  assert.equal(ref, `#${id}`)
})
{% endhighlight %}

In the end we access the `shadowRoot` of the element and find the property we want to assert on via `querySelector`. Easy enough for now.

Of course the example above might be considered simplistic. There are no HTTP request and the components are not nested (components within components within components...)

But for now the above should serve as an introductory example.
