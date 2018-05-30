---
layout: post
title: "Basics and Beyond"
date:   2018-05-20 18:55:17
description: ""
category:
tags: []
---

Being around for a while each of us might have seen the following lines

{% highlight bash %}
if [ -z $1 ]; then
  echo "please provide the input parameter foobar"
  exit 1
fi

# do some work
{% endhighlight %}

In the wild it can be found at the beginning of a bash script.

Apparently the script requires an input and fails if the length of the input is zero. If the length is zero it's not present. Thus the `-z`.

The author thought without the input it would make no sense to continue with the execution of script. As a result we exit with a non-zero status (`exit 1`).

After a quick search for _"bash check if input is provided"_ we could grab the above straight from [Stackoverflow](https://stackoverflow.com/questions/6482377/check-existence-of-input-argument-in-a-bash-shell-script). No further consideration. It's fine ;)

Hold on! Let's have fun with the shell.

_Regard `>` as the prompt and the line which follows afterwards as the output._

{% highlight bash %}
> [ -z "not empty"
[: ']' expected
> [ -z "" ] && echo "is empty"
is empty
{% endhighlight %}

Hah. Seems like `[` is a command. No `if` required.

Check out the manual

{% highlight bash %}
> man [
{% endhighlight %}

Where we find the docs of the `-z` argument stating

> -z string     True if the length of string is zero.

It also states `[` is the utility `test`. In fact we're able to interchange `[` with `test`

{% highlight bash %}
> test -z "" && echo "is empty"
is empty
{% endhighlight %}

We can even build an alternative to `test`. Formulate the most important requirements into tests. Voila. A home grown testframework which consists of a single function

{% highlight bash %}
failed() {
  echo "failed"
  exit 1;
}

./assert-empty "hi" && failed
./assert-empty "" || failed
./assert-empty || failed
{% endhighlight %}

So `&& failed` leads to a failure if the command before exits successfully. Which it should not.

And `|| failed` triggers if the command before exits unsuccessfully. Which again, it should not.

Our quick and dirty implementation in [C](https://en.wikipedia.org/wiki/C) follows. If we have no input or if the input has a length of zero we exit successfully.

{% highlight c %}
#include <string.h>

int main(int argc, char *argv[]) {
  if (argc == 1 || strlen(argv[1]) == 0) {
    return 0;
  } else {
    return 1;
  }
}
{% endhighlight %}

We compile the above

{% highlight bash %}
gcc -o assert-empty assert-empty.c
{% endhighlight %}

And run the tests

{% highlight bash %}
sh ./test-assert-empty
{% endhighlight %}

Success!

Copy the compiler output to `/usr/local/bin` to reuse it

{% highlight bash %}
cp assert-empty /usr/local/bin/
{% endhighlight %}

The script above could now start with

{% highlight bash %}
if assert-empty $1; then
  echo "please provide the input parameter foobar"
  exit 1
fi

{% endhighlight %}

We should not use it in scripts though. Their portability would be destroyed. Only our system will have the `assert-empty` utility.

Having a look at the [original source of test in C](http://git.savannah.gnu.org/cgit/coreutils.git/tree/src/test.c) we find it offers a lot more than our `assert-empty`. It had time to mature. The commit `Initial revision` of the file dates back to November 1992.

Spelunking around the `tests` folder of the repository we find how `test` is used to test other coreutils, such as `rm`.

Check out some cool parts in one of the [files](http://git.savannah.gnu.org/cgit/coreutils.git/tree/tests/rm/rm1.sh) used to test `rm`

{% highlight bash %}
mkdir -p b/a/p
#...
rm -rf b
#...
test -d b/a/p || fail=1
{% endhighlight %}

We recognize the classic [Arrange-Act-Assert](http://wiki.c2.com/?ArrangeActAssert).

* __Arrange__: We create a directory.
* __Act__: We delete the directory
* __Assert__: We verify whether it still exists with `test`

Thus what seemed like an innocent bracket `[` helps to make sure the foundations we build upon run smoothly.
