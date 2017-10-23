---
layout: post
title: "Lesser known git concepts"
date:   2015-07-05 17:15:15
description: ""
category:
tags: [git]
---
Its been six months since I've been part of switching the last project still running on SVN to git. Most of the developers in the project had not yet have the luck of working with git. After introducing the team to git and answering questions over the course of the following months i’m trying to give an overview of the two most common unknown concepts in git I've encountered.

## Understanding labels
Following I'll use the term "label" for concepts such as branch and tag.

The git history is a graph that contains nodes (commits) that are linked.

After checking the log of a repository you might see the following:
![initial](https://www.dropbox.com/s/rnqvpincqgjguuy/init.png?raw=1)

You can see two labels `HEAD` and `master` both pointing to the commit with the shortened hash `5c73fcf`. `HEAD` points to the current commit we have checked out. As a result `git checkout HEAD` will never change anything as we are always already on the commit where `HEAD` points to. The other label `master` points to the last commit created in our master-branch.

After `git checkout -b new-branch` it looks like this:
![after_branch](https://www.dropbox.com/s/fwchwmgvwacvpxd/after_branch.png?raw=1)

Now we have one more label that points to the only existing commit.

That's all it took to create a branch. No copies necessary as in SVN.

After creating a new commit on our `new-branch` the log looks like:
![first_commit_in_branch](https://www.dropbox.com/s/d1l6uhyjtxb44kz/first_commit_in_branch.png?raw=1)

The `HEAD` and the `new-branch` label has moved forward.

Now we want to merge the new feature back into our master branch. We create an explicit merge commit via
`git merge --no-ff new-branch`

![after_merge](https://www.dropbox.com/s/wd1nrn98t6glm88/after_merge.png?raw=1)

The `HEAD` and the `master` label has moved forward. `new-branch` is still available as a reference to the tip of the feature branch.

Now we tag our release via
`git tag v2.7`

![tag](https://www.dropbox.com/s/21gklvuzzu5jl22/tag.png?raw=1)

As we continue to create commits `HEAD` and the branch label will move on. The tag will stay.

The difference between a tag and a branch is that a tag can't be moved (without deleting and recreating it)

This knowledge should help dealing with questions like

> If i create a tag on the commit of the tip of a branch and then delete this branch, can i go back to it?

Yes. As the branch label has just pointed to a commit so does the tag.

> It states that I'm in 'detached HEAD' state. What does this mean?

You are on a commit that has only one label point to it (`HEAD`) when you create commits now and then say check out `master` again the connection to your previous commits is lost because no label points to them.

The whole references and labels concept is very nicely explained in [Git For Ages 4 And Up](https://www.youtube.com/watch?v=1ffBJ4sVUb4). Don't be quenched by the title :)

## Changes removed by a hard reset are gone
There is a fear that if should you ever type in something like `git reset HEAD~1 --hard`, which deletes the commit `HEAD` currently points to, is lost irretrievably. This is not true thanks to the concept of `git reflog` which I'm going to showcase here:

Lets say you have created a new feature branch `awesome_feature` and created the first commit in it.
![hard_reset_init](https://www.dropbox.com/s/hmgox9mtjy90kbe/hard_reset_init.png?raw=1)

Now we delete this commit via `git reset HEAD~1 --hard` and realize we want to have the commit back.
After you type `git reflog` you will see:
![reflog](https://www.dropbox.com/s/f5pw5kp5c9a00vr/reflog.png?raw=1)

We can now go back to the state before the deletion via
`git reset --hard 6a81aa2` and were back to:
![hard_reset_init](https://www.dropbox.com/s/hmgox9mtjy90kbe/hard_reset_init.png?raw=1)

Still, the full reflog will not be there forever. Git will clean it periodically.
