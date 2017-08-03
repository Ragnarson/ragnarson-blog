---
title: How to choose a bug tracker for a small startup team
author: wijet
cover_photo: cover.png
tags: entrepreneurship
---
Choosing a project management tool isn’t an easy task. There are tons of SaaS/web-based issue tracking tools out there (like with TODO apps for personal use.) Quora and Stack Exchange threads are full of comments written by marketing teams about these tools. It’s as easy to overshoot and choose a massive product, packed with hundreds of features, that cripples your productivity and joy, as undershoot and end up with a service that you will outgrow in a matter of weeks.

I assume that you run a small startup company. If that’s true you will most likely have two areas to align. Some kind of software product or products and the company itself. The latter includes things like marketing, recruitment, employees’ on-boarding, etc.

In our 10 years of experience we have found that these two areas are different matters and require quite different tools. Running an agile software development project requires a strict and repeatable process of defining, estimating, planning, developing, testing and deploying. There is a deadline, a list of milestones broken down into smaller tasks etc. Those are the industry standards. On the other hand, marketing or sales isn’t that “linear” at the beginning and it often differs from company to company. Committing to pay for HubSpot or Salesforce from the very start might be an exaggeration and a shot in the dark.

## Why is it important to choose the right tool?

Your workflow within a project management tool influences factors like ease of planning, efficient execution of the plan, progress tracking, teamwork and overall team motivation. What is more, once you commit to one solution it’s not that easy to migrate halfway through (because of the vendor lock-in.) Sure, there are migration tools, but in my experience, for anything larger than a pet project, it’s never a matter of only pushing a button.

To give you more context, we have completed over 50 projects with various project management tools, from modern issue trackers to real dinosaurs. We used [Trac](https://trac.edgewall.org), [Redmine](http://www.redmine.org), [Lighthouse](https://lighthouseapp.com), [Pivotal Tracker](https://www.pivotaltracker.com), [Trello](https://trello.com), [Basecamp](https://basecamp.com), [Jira](https://www.atlassian.com/software/jira), [GitHub Issues](https://guides.github.com/features/issues) (with and without [Huboard](https://huboard.com).) And we were lucky enough to test numerous others because from time to time the client already had his tool of choice in place. The size of the teams varied between 2 and 20 people. We always use [“agile-ish” methodology](https://en.wikipedia.org/wiki/Agile_software_development) with weekly sprint meetings.

## What to look for when choosing a tool for a software development project

In our experience agile methodology is perfect for startups and small companies. That’s why we lean towards tools that support this “flow”. When running a technical startup and using a project management tool you want to be able to:

* Plan tickets for the two to three upcoming weeks and see the plan on one screen. So it’s clear what, when and in what order.
* Get time or complexity estimations from developers on every ticket, so you can prioritize stuff.
* Monitor project’s velocity.
* Handle hundreds of tickets on one screen (you don’t want to scroll back and forth).
* Quickly see what’s in progress, what waits, quickly distinguish features, from bugs and from chores.

Based on the above requirements, we have been using Pivotal Tracker for most of our software development projects. For projects from €15.000 to €1M, from 2 months up to 3 years and counting, from 2 up to 15 people involved in the project. It’s kind of like Ruby on Rails in the Ruby frameworks world. It follows a convention over configuration principle, thus most of the concerns of the software development in a lean startup company are addressed from the very start.

Here is an example Pivotal Tracker board (project).

![Example Pivotal Tracker project ](2017-07-14-how-to-choose-a-bug-tracker-for-a-small-startup-team/example-pivotal-tracker-project.png)

Similar to Pivotal Tracker is Jira. It’s much more flexible, so it allows you to design your own flows. For example, a ticket can start as an idea, go through a designing phase by a design team, then through implementation, user experience testing by one team, again through implementation, deployment by another team, A/B testing and so on.  However, you have to pay for the flexibility with administrative time and ease of use.

## What to look for when choosing a project management tool for less technical stuff

Besides the software product, there will be other matters to be organized in your company. Things like orchestrating sales and marketing efforts, recruitment processes or onboarding/offboarding employees’/client’s projects. Based on our experience such a tool should allow you to:

* Create multiple named lists, so you can map your process (funnel) properly
* Create multiple checklists within tickets; so for example, when recruiting for the 10th time none of the steps will be forgotten (and you have this feeling of accomplishment when checking a task within a list)
* Allow tickets and board templating; there are tons of use cases here, a template for a recruitment candidate card, a template for project’s onboarding board, etc

Here we suggest using Trello. Workflows in each of the “departments” tend to differ and Trello boards can be easily adapted to represent them. The tool will adjust to you and not the other way around. What is more, it’s very intuitive and easy to use even for a non-technical person.

Below is a hiring board by [42Hire.com](https://42hire.com):

![Hiring funnel Trello board by 42Hire.com ](2017-07-14-how-to-choose-a-bug-tracker-for-a-small-startup-team/42-hire-hiring-funnel-trello-board.png)

You can [read more](https://42hire.com/how-you-can-use-trello-to-organize-your-hiring-funnel-2d36caad9023) about how they mapped a real hiring process (funnel) into Trello board.

Trello is also great for presenting a process or information that a certain person has to follow or be aware of. A really useful example is an employee onboarding board. When a new employee joins the team, a copy of this board is created just for her/him to follow.

![](2017-07-14-how-to-choose-a-bug-tracker-for-a-small-startup-team/example-trello-employee-onboarding-board.png)

More inspirations on how to use Trello can be found on [Trello inspirations page](https://trello.com/inspiration).

## Pivotal Tracker vs Trello

Sometimes I get this question, “ok, but which one is better?”. The answer is as always, “It depends”. It’s hard to compare these tools because they are intended for different tasks. Once we took over a software project run on Trello and it was a nightmare. Hard to navigate through countless tickets, hard to estimate and tell how long tickets would take and how to tell what’s important given the available time. We had to build some kind of system on top of it. On the other hand, I can’t imagine squeezing PT flow into recruitment or onboarding.

We are always excited about new stuff and haven’t tried everything. Share in the comments your favourite project management tools. You can also contact me at wijet at ragnarson dot com.
