---
title: How I work on new features
author: bkzl
---

*tl;dr Collect feedback from your customers; always plan what to do next; think about the user interface before you start writing code; discuss with your team your current work often; test what you have done.*

Many developers encounter a variety of difficulties when they have to work on new features. From things like: "how exactly should I start?" to more complex issues, for example, in the middle of a development, they notice that everything they have done is wrong and that it is necessary to start over. Therefore, I have decided to share information about my workflow and how I usually get things done.

Please note that the described process refers to working on a new feature from an individual perspective. I understand that in most scenarios, the work is delegated to a number of people. I may have even exaggerated in some cases when it comes to simple tasks, but this is due to the fact that my main focus is on ideas; ways to help you avoid making mistakes as early as possible in the process.

## Which feature should I implement?

Essentially, every feature you want to add should be added as a consequence of your customer’s needs. Don't solely depend on your own guesswork, as quite often, you could be the only person who thinks that a particular feature is important and necessary. Always try to verify your assumptions with raw data. The easiest way to start with this is by obtaining feedback from your clients. Use tools like email, surveys or even better: simply talk with them. Of course, you don't have to discuss every minute detail with the customer, but be mindful of the fact that generally, evaluating customer needs is a crucial practice. Moreover, there are services like [Intercom][intercom], [Mixpanel][mixpanel] or [Kissmetrics][kissmetrics] which can really help understand how people use your application, discovering what problems they encounter and what would work better. Don't forget to think about the fit of a new feature in terms of your business. Compare the advantages and disadvantages and ensure it's is a good move. If you determine that your idea makes sense, create a new task in your tickets tracker and explain it to your team.

## Make a good plan

How should you start? First, conduct good research. There is a good chance that the thing you want to do has already been done by someone else. Explore sites with user interface patterns (like [pttrns][pttrns] or [goodui][goodui]). Do you want to allow your users to manage account settings for example? If so, study websites which you use every day. See how they solve this problem, compare their solutions and consider which has the most suitable answer in your opinion. Think which parts of the UI make it work and which parts annoy you. Don't be afraid to learn from others.

Ok, so you have got some general ideas about how your feature should work. Now, write this down on a sheet of paper or in your preferred text editor. List all the parts which form the feature as a whole:

```
Account Settings Page
---------------------
Avatar
Two-factor authentication status
Allow to change email and password
Allow to manage ssh keys
Login with username
```

Next, strike off all the points which aren't required in your first iteration and then sort them by priority.

```
Account Settings Page
---------------------
Two-factor authentication status
Allow to change email and password
Allow to manage ssh keys
```

```
Account Settings Page
---------------------
Allow to change email and password
Two-factor authentication status
Allow to manage ssh keys
```

When you have this ready, talk to your team once again.

The last step in this section is to divide each point into the smallest possible tasks. Do this frequently, even during the regular development. It's better to have twenty tiny and verifiable to-do’s than one large to-do accompanied by countless details. When you are coding, this ensures that you are able to finish things instead of stressing out over the fact that you can't deliver your work for two weeks.

## First, design the User Experience

Check your list of positives and negatives and design the interface. It doesn't have to be perfect, but try to visualize the user experience as a whole. Choose the design technique which gives you the fastest feedback. Here are some example methods:

- Sketch on paper
- Make a mock-up. I prefer an app called [Balsamiq Mockups][balsamiq-mockups] for that.
- Make HTML & CSS only prototype. Don't worry about the quality of your code, you will fix it later.
- Take a screenshot of your existing page, load it into the graphic editor and design new elements on top of it. [Sketch][sketch] app is very good for this.

Update and discuss with your team the designed interface.

## Writing code

When you have a designed interface and user flow it's time to make it work. Again, before you write your first line of code, it's a good idea initially to think about the implementation. Consider classes which you will need, the relations between them, how to store data in the database and how to test your code. Through a little planning, you can avoid so many problems whereas starting to code immediately without seeing the bigger picture invites problems.

Regarding the code, start by writing some very general integration tests covering the whole feature. After that, implement in detail all views as static pages. All backend work on logic should be done at the end. Work on the highest abstraction first, slowly moving to low-level parts.

When you finish, create a pull request and spend some time on your code quality; review and refactor it. Once everything is ready, push your new feature to production.

## Post-release

You are not done yet! Besides the changelog update and notifying your client’s about the new functionality, e.g. a blog post, you should immediately start obtaining feedback about your latest feature. Ensure that everything works as expected. Set up A/B tests. Iterate on existing features to improve them. Don't be afraid to remove those which nobody uses and which don't fit your business.

[intercom]: https://www.intercom.io
[mixpanel]: https://mixpanel.com
[kissmetrics]: https://www.kissmetrics.com/
[pttrns]: http://pttrns.com/
[goodui]: https://www.goodui.org/
[balsamiq-mockups]: https://balsamiq.com/products/mockups/
[sketch]: http://bohemiancoding.com/sketch/
