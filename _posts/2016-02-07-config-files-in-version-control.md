---
layout: post
title: "Configuration Files in Version Control"
date:   2016-02-07 14:01:23
description: ""
category:
tags: []
---
In some projects we encounter configurations that are stored in the [VCS](https://en.wikipedia.org/wiki/Version_control). If it's, `.xml`, `.yaml` or `.properties` etc. does not matter. As an example consider a typical `config.json` file

{% highlight json %}
{
  "DATABASE_URL" : "postgres://foo:@localhost/bar",
  "DATABASE_PW" : "opensesame",
  "SERIAL_PORT" : "/dev/ttyACM0"
}
{% endhighlight %}

There are multiple issues with this approach. The credentials could be confidential and different between environments. For example a developer might want to connect to his own database. The settings differ across platforms in use. To connect to a USB port on GNU/Linux you would use a name like `/dev/ttyACM0`. While on OSX it's `/dev/tty.usbmodem1A1211` and on Windows `COM7`.

What we see happening is developers edit these files to their liking and _try_ to not check their changes into version control. Sooner or later these files will be checked in accidentally. Even if it never happens, thinking about not forgetting it is just another constant burden on the mental capacities of the developer.

Others, well versed with [Git](https://git-scm.com/), will try the following to ignore changes made to the file

{% highlight bash %}
git update-index --assume-unchanged config.json
{% endhighlight %}

No we at least avoid checking in our personal settings. That is until another developer decides to change the structure of the file and on the next pull from remote you will see

{% highlight java %}
error: Your local changes to the following files would be overwritten by merge:
config.json
{% endhighlight %}

Now you have to

{% highlight bash %}
git update-index --no-assume-unchanged config.json
git stash
git pull
git stash pop
{% endhighlight %}

and then resolve your merge conflict. Tedious.

How can we resolve this?

An idea of using environment variables stems from [The Twelve-Factor App](http://12factor.net/), especially the [Store config in the environment](http://12factor.net/config) part.

The gist of the article is the following quote

> A litmus test for whether an app has all config correctly factored out of the code is whether the codebase could be made open source at any moment, without compromising any credentials.

Now we could go through the code base and replace every read on the config file with environment variable usage. Doing this will take time, you probably don't know in what places the config file is used. Worse, it might break existing functionality. Then it has to be prioritized by the business and will probably become a [Planned Refactoring](http://martinfowler.com/articles/workflowsOfRefactoring/#planned) ticket to wander off into the depths of the backlog. Only to be implemented by our grandchildren.

As a proponent of taking tiny steps I suggest another approach. Let's first remove the biggest pain point. The fact that the `config.json` is in version control. Let's generate the file when running the program.

The best case would be if you already have a `run.sh` script which hides how the program is started.

{% highlight bash %}
#!/bin/sh

npm start
{% endhighlight %}

We can extend it to generate the `config.json` using the environment variables. Lets first make sure the environment variables are set when starting the script.

{% highlight bash %}
set -e
: ${SERIAL_PORT:?}
{% endhighlight %}

The script will exit if the environment variable is not set.

{% highlight bash %}
./run.sh: line 4: SERIAL_PORT: parameter null or not set
{% endhighlight %}

Set it with

{% highlight bash %}
export SERIAL_PORT=/dev/ttyACM0
{% endhighlight %}

Now lets use the environment variable above. The `config.json` file can be created via the `tee` command.

{% highlight bash %}
rm -f config.json
tee -a config.json >/dev/null <<EOF
{
  "DATABASE_URL" : "postgres://foo:@localhost/bar",
  "DATABASE_PW" : "opensesame",
  "SERIAL_PORT" : "${SERIAL_PORT}"
}
EOF
{% endhighlight %}

We recreate the config file on every run with the current settings. The direct access of the `config.json` file in the codebase can now be replaced bit by bit as you stumble over them by using the defined environment variables.

You can define the environment variables to be always set in your `.bashrc` file or just create an alias as follows

{% highlight bash %}
alias run_projectxy='export SERIAL_PORT=/dev/ttyACM0 && ./run.sh'
{% endhighlight %}
