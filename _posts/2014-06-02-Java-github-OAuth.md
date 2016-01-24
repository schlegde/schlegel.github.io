---
layout: post
title: "GitHub OAuth with Java"
date:   2014-06-02 22:05:15
description: ""
category:
tags: []
---
[OAuth](http://en.wikipedia.org/wiki/OAuth) is commonly used as a way for web surfers to log into third party web sites using their Google, Facebook or Twitter accounts.

In the example [Basics of Authentication](https://developer.github.com/guides/basics-of-authentication/) for the GitHub OAuth they create a Ruby server to show the [Web Application Flow](https://developer.github.com/v3/oauth/#web-application-flow) for using OAuth with GitHub.

Basically the Web Flow consists of three parts:

1. Your app redirects the user to GitHub to request access.
2. GitHub redirects back to your site with a temporary code that can be exchanged for an access token.
3. With the temporary code the access token to access the GitHub API can be requested.

The different GitHub Java-API's all require the Access-Token. Accordingly we need to get the Access-Token first before we're able to use those libraries.

In the following example we want to use Java, the [Spark Web Framework](https://github.com/perwendel/spark), the Rest-client [Unirest](https://github.com/Mashape/unirest-java) and the template engine [freemarker](http://freemarker.org/) to achieve the same functionality of the Ruby server in the [Basics of Authentication Guide](https://developer.github.com/guides/basics-of-authentication/).

The following code can also be found on [GitHub](https://github.com/xorrr/githuboauth).

## Create a basic server

First [register](https://github.com/settings/applications/new) a new OAuth application.
Use `http://localhost:4567/callback` as the *Authorization callback URL*. The Client ID and Client Secret should be stored as environment variables:

{% highlight bash %}
export GH_BASIC_CLIENT_ID=97xor4b13d58cc5a5b42
export GH_BASIC_SECRET_ID=553foobd8f4c06c211232barbaze15e988405b42
{% endhighlight %}

Create the template `index.ftl`:
{% highlight html %}
<p>
  We're going to now talk to the GitHub API. Ready?
  <a href="https://github.com/login/oauth/authorize?
  scope=user:email&client_id=${client_id}">
  Click here
  </a> to begin!</a>
</p>
<p>
  If that link doesn't work, remember to provide your own
  <a href="/v3/oauth/#web-application-flow">Client ID</a>!
</p>
{% endhighlight %}

Create the `FreeMarkerTemplateEngine` class, that will render the template:

{% highlight java %}
public class FreeMarkerTemplateEngine extends TemplateEngine {

    private Configuration config;

    protected FreeMarkerTemplateEngine() {
        this.config = createFreemarkerConfiguration();
    }

    @Override
    public String render(ModelAndView modelAndView) {
        StringWriter sw = new StringWriter();
        try {
            Template t = config.getTemplate(modelAndView.getViewName());
            t.process(modelAndView.getModel(), sw);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return sw.toString();
    }

    private Configuration createFreemarkerConfiguration() {
        Configuration c = new Configuration();
        c.setClassForTemplateLoading(FreeMarkerTemplateEngine.class, "freemarker");
        return c;
    }
}

{% endhighlight %}

Create the route displaying the template. Provide the `client_id` to the template.
{% highlight java %}
get("/", (request, response) -> {
            Map<String, Object> attributes = new HashMap<>();
            attributes.put("client_id", System.getenv("GH_BASIC_CLIENT_ID"));

            return new ModelAndView(attributes, "index.ftl");
        }, new FreeMarkerTemplateEngine());
{% endhighlight %}

Create the callback route and access the provided session code (`code`):

{% highlight java %}
get("/callback",(request, response) -> {
                    String sessionCode = request.queryParams("code");
});
{% endhighlight %}

Use the session code to

{% highlight java %}
String accessToken = Unirest.post("https://github.com/login/oauth/access_token")
         .header("accept", "application/json")
         .field("client_id", System.getenv("GH_BASIC_CLIENT_ID"))
         .field("client_secret", System.getenv("GH_BASIC_SECRET_ID"))
         .field("code", sessionCode)
         .asJson().getBody().getObject()
         .get("access_token").toString();;
{% endhighlight %}

With the access-token we're ready to use the GitHub API. For example to get the username for an access-token:
{% highlight java %}
String username = Unirest.get("https://api.github.com/user?access_token="+
    accessToken).asJson().getBody().getObject().get("login").toString();
{% endhighlight %}

But you should probably use a [specialized library](https://github.com/kohsuke/github-api) instead of accessing the API through REST.
