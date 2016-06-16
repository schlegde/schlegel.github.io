---
layout: post
title: "Continuous Integration"
date:   2016-05-02 18:00:00
description: ""
category:
tags: []
---
When discussing continuous integration (CI) one might find projects and teams stating they _have_ CI because they employ CI-Tools such as [Jenkins](https://jenkins.io/) or [Travis-CI](https://travis-ci.org/). We believe CI is not something you _have_ but rather something you _do_.

Before proceeding let's have a look at [Wikipedia](https://en.wikipedia.org/wiki/Continuous_integration) to define CI as:

> Continuous integration (CI) is the practice, in software engineering, of merging all developer working copies to a shared mainline several times a day.

There is no mention of CI-Tools. If every developer on the team integrates his changes into be master branch on a daily basis then the team is doing CI. Feature branches that are kept open longer than a day are not acceptable. It goes without saying that the code in master should always build successfully and pass all tests since everyone depends on it.

You might be asking: "How are we going to implement a feature that takes weeks or months to implement if we can't create feature branches?". To solve the same issue in [Relution](https://www.relution.io) we enjoy using [Feature Toggles](http://martinfowler.com/bliki/FeatureToggle.html).

The server provides a list of features that are currently under construction. Our clients then use the list and decide which features the users should see. As a result, the customer never sees a feature that is currently being built, while the developers and the product managers see all features. As soon as the feature is finished we can remove it from the list to allow every user to see and use it. Take a gander at [Feature Toggle Framework List](http://enterprisedevops.org/feature-toggle-frameworks-list/) for some inspiration on how to implement the feature toggles.

Having explained how the daily integration of branches can be achieved lets look some of the benefits:

* Progress can be measured by working software. There will be no feature branch in the dreaded _almost done_ state. Every member of the team can look at the client and see the progress of a feature. We have the possibility to interact with all parts of the feature that are ready. Allowing us to take early countermeasures if the feature diverges from the concept.
* Since huge changes to the codebase are split into multiple small integrations, we never have to review 50 commits that have a diff spanning over multiple hundred lines. This leads to a less error prone code review process as it's easier to spot issues in a small change than in a huge change.
* Bugs are detected earlier since every developer works on the same state of the code base.
* Possibility to [Refactor Mercilessly](http://c2.com/cgi/wiki?RefactorMercilessly) since the chance of breaking the implementation of a feature branch is non existent.

Although CI can be achieved without a CI-Tool, see [Continuous Integration on a Dollar a Day](http://www.jamesshore.com/Blog/Continuous-Integration-on-a-Dollar-a-Day.html) for more, we at [Relution](https://www.relution.io) use Jenkins to help us having the master branch in a state where the build is always successful and passes all tests. Before merging changes into master they have to be built by Jenkins, passing all their tests. Following this process the master should almost never be broken. If, for some unforeseen reason, it gets broken the primary focus of the team now shifts to getting it back to a working state. To make this work the team needs to understand the value of CI and be committed to it.

The practices above become easier the shorter the duration of a build is. If the build takes ten minutes it takes at least ten minutes to get the build from a broken state back to a working state. With a lengthy build the process becomes harder. Imagine the build takes an hour. You create a merge request and Jenkins will need one hour to prove the result still builds. Another hour of build time is added after the requester has fixed issues which arose during the code review. As a result it took two hours of build time, not counting the time spent on the code review and ensuing issues, for a single integration. Striving for a fast build is of paramount importance to make working with the CI process painless.

CI is not easy, or as Jez Humble, author of [Continuous Delivery](http://continuousdelivery.com/), [remarks](https://www.youtube.com/watch?v=_wnd-eyPoMo#t=6m):

> Continuous Integration is super hard, it's not running Jenkins on your feature branches and then ignoring the build when it goes red.

Regardless, we accept the challenge, knowing the benefits of rigorous CI are worth it.
