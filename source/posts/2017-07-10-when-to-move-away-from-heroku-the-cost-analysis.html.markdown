---
title: When to move away from Heroku - the cost analysis
author: macias
cover_photo: cover.png

---
# The problem

Are you using Heroku or a similar provider and you are not sure how cost-effective it is in the long run?

Are there other limitations of a Platform-as-a-Service of your choice and it would be great to know how expensive and complicated it is to migrate if necessary?

If you are concerned by either of these let me show you if and when it’s worth to start considering a change.

READMORE

# The tool

Based on years of experience on both ends ([our own PaaS](https://shellycloud.com/), [customized solutions](https://ragnarson.com/services/infrastructure-and-devops/?utm_source=blog&utm_medium=blogpost&utm_campaign=heroku-cost)), we created a simple tool for comparing the price between Heroku and a customized solution. The bespoke platform consists of a code which sets up all services on top of a server infrastructure provider (AWS in our example) and is maintained and supported by a team of administrators.

['Heroku vs a custom solution based on AWS - the cost analysis' spreadsheet](https://goo.gl/6rZDkU)

[![Heroku vs a custom solution based on AWS](2017-07-10-when-to-move-away-from-heroku-the-cost-analysis/screenshot.png)](https://goo.gl/6rZDkU)

All prices are based on our own experience in building hosting solutions. Please keep in mind the spreadsheet may not be sufficient to make real life decisions regarding your hosting needs. The purpose is to help you find the ballpark cost when PaaS solutions (Heroku in our example) stop being cost effective in the long run. There are many aspects that make both options hard to compare. We made certain simplifications and assumptions described below. Feel free to make your own copy and adjust the numbers to your situation and requirements.

## Where do we break even

There are 2 important takeaways from the spreadsheet:
 
The first case is an app or a set of apps with requirements of around 168GB of RAM and an estimated cost of $7620 with premium support on Heroku.
 
The custom solution **saves around $1001 monthly** and gives **a return of investment after 15 months**.
 
The second case is an app or a set of apps with requirements of around 112GB of RAM and an estimated cost of $4350 without support on Heroku.
 
The custom solution **saves around $1085 monthly** and gives **a return of investment after 14 months**.

# Similarities

Even though both solutions are not perfect substitutes, they provide a similar set of features important from the developer and business owner standpoint:

* Git-based deployment
* Ease of scaling up
* High Availability
* Backups
* Security
* Infrastructure and application monitoring

# Assumptions and simplifications

In order to make the spreadsheet relatively simple, we introduced certain assumptions and simplifications:

* We rely on AWS as an Infrastructure-as-a-Service layer because it is industry standard and one of the most mature providers.
* We chose ‘m4’ instances because of their universal characteristics and the fact that they are not oversubscribed.
* The proposed databases are entry level solutions. In real life it is going to be more expensive. The price on Heroku usually grows faster.
* There are many technical differences where importance varies from project to project, which are not taken into account.
* We don’t include any add-ons (e.g. Elasticsearch). As a rule of thumb, most of them are more expensive on Heroku in the long run. The cost of setup is usually recovered after a few months.
* The prices related to the development and maintenance of a custom setup are based solely on our own experience and may vary significantly among providers.
* Certain variables like the maintenance cost will grow with scale. We didn’t take that into account because the marginal cost is relatively low and it varies from project to project.

# Summary

I hope, the presented tool is going to answer at least some of your questions. Feel free to leave a comment and let us know what would you like to learn about next. Please keep in mind that any actual implementation requires a much more thorough analysis. The spreadsheet’s role is to help you understand the ballpark cost. If you would like to go into details just drop me a line at [macias@ragnarson.com](mailto:macias@ragnarson.com) and check [what kind of problems](https://ragnarson.com/services/infrastructure-and-devops/?utm_source=blog&utm_medium=blogpost&utm_campaign=heroku-cost) we solve for our clients.
