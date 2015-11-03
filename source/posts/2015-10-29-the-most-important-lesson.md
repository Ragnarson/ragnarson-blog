---
title: The most important lesson
author: dawid
---

Before working for Ragnarson I was a Rails developer for nearly 2 years. When I finally became one of the "Perfect Programmers", I considered myself a guy who knew enough stuff to take another step forward. I felt ready for new challenges. But it quickly turned out that there was one important skill I was missing which was not related to any technical knowledge. In simple terms, I can say now that I wasn't 100% professional about my work. But what exactly does that mean? READMORE

I got some bad habits from one of my earlier projects. It needed a lot of hotfixes and interventions directly on the production database, and all because of not so great code, some missing tests, and fast approaching deadlines. So, from the beginning of my journey with Rails, I thought that this kind of situation was just a normal, typical development process.

Then I started working on my first project with Ragnarson, I had to finish some task rather quickly and from the beginning I knew that it would be hard to do, but instead of splitting it into smaller tasks and discussing it deeply with client, I just started implementing it right away. In the end, the new feature was delivered, but it was kinda sloppy. So, what was wrong with it at first glance?

* Low-quality code – obviously;

    Little things - bad naming, moving some logic to view layer, etc. All small things that add up to one big maintenance hell in the future, and they are bug prone.

* Mess in git history;

    Lack of commit descriptions, which can be crucial in understanding the code in the future, unnecessary merge commits, putting too many functionalities in one commit or maybe putting irrelevant changes in commits.

* Lack of good tests;

    There was even one bug which I introduced, and it was a little surprising to find it later because the tests were there! The problem was my specs were not covering all of the edge cases.

So I finished my task, the client was happy with what he saw, and I was happy I did manage to complete everything in time. Then I got my first big code review, and it hit me right away. Even when I was looking at my own code written some time ago, I saw so many places where I could have done something better.

I think that particular code review gave me my most important lesson as a developer. There is no one else to blame for your own, poorly written code. Of course there are deadlines, maybe a client can be hard to communicate with and your team can have different perspectives on the current problem, but in the end you have to be responsible for your code. That's what being 100% professional is all about.

So what does it mean exactly for us developers? We can simply look at all of the mistakes I made earlier and try to turn them around.

* Communicate with your client. Ask a lot of questions and be honest about estimating your work. Remember, over communication is better than lack of communication.

* Don't hurry. Do some research, plan your work, write less code but write better code. After you finish your task, review your work deeply, try to find code smells and refactor them before you even create a pull request.

* Test your application, cover some edge cases and run your tests often. Every commit should be “green”, that is, all specs should run without any fails on every commit.

* Take care of your git history. Take some time to write meaningful descriptions of your commits and explain why this change is needed.

* Leave the campground cleaner than you found it - aka the "Boy Scout rule". Always try to find some little thing to refactor. It can even be very small, like changing a variable name to be more adequate, moving some code around to its own class or simply fixing indentation. This way your codebase will slowly get into better shape.

## Wrapping up

So what exactly does differentiate good developers from people who simply know how to write code? I think that really good developers know that something is not finished until they are sure they did their best and they will deliver high-quality product. Just be professional and be responsible for your work.
