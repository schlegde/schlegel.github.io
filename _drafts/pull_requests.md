# Micro Pull requests

There are [Microservices](https://en.wikipedia.org/wiki/Microservices), [Micro Commits](https://lucasr.org/2011/01/29/micro-commits/), [Microbreweries](https://en.wikipedia.org/wiki/Microbrewery) and there is what I would call Micro Pull Requests, or Ninja Continuous Integration if we want to be really fancy.

What's Ninja about it?


We could call it continuous integration. What they mean is long lived feature branches. What is considered long lived? Let's take a day. A branch created at 12 PM should find its way into master until 12 PM the next day. Corey Haines has some [intriguing thoughts](http://articles.coreyhaines.com/posts/short-lived-branches) on it

Teams might have a policy in place that every change of the codebase has to go through a review process. This is often achieved via pull requests. Of course like every policy it has it issues.

It reaches from pull request which have a size so huge that your WebUI refuses to render it or the reviewer does not care about it as much as to spend hours reviewing it and just waives it through.

Pull requests which would not meet any of the quality standards but since tomorrow theres a spring review and the story should be done until then.

Others are assigned to specific members of the team you know won't complain if there are zero tests.

While Martin Fowler calls it [preparatory refactoring](https://martinfowler.com/articles/preparatory-refactoring-example.html) and [Kent Beck summarizes it as](https://twitter.com/kentbeck/status/250733358307500032?lang=de)

> make the change easy then make the easy change.

Thus the steps of the preparatory refactoring are it's own pull request.

Campground rule. Scout rule, you track down a bug oder want to understand a piece of code. You see something which can be improved you improve it and create a pull request.

Something has an outdated version? Increment it to the latest version and create PR. There are services automating this.

# Challenges

Of course there are some downsides to Micro Pull Requests. One is how people might be prone to losing the bigger picture. For example if we have a PR containing some preparatory refactoring, a PR creating clients to connect to a third party system and a PR providing a stubbed out REST API. Since there were thus three merges already someone might think "Isn't this ticket already done? There have been three merges already" when in reality there is still something left, e.g. a service layer using some results of the third party system to enrich it and make connect it to the, until then, stubbed out REST API.

Another issue are long build times, if
