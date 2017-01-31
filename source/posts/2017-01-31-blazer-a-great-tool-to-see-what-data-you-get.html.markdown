---
title: Blazer - a great tool to see what (data) you get
author: piotr
cover_photo: cover.png
---

No matter what kind of online business you run, you also collect some data. To be honest we collect and store more and more data nowadays. The problem is that almost no one understands collected data and it cannot be used to make better business decisions.

READMORE

The reason is simple. Database tables are hard to read. It is not easy to see trends and makes assumptions based on the raw table view.

You can think you need a data scientist to get a useful knowledge of your data. It is not true. You just need to see it in a new way. Visualize it to help you understand what is hidden in the data.

In rails world, we have some free gems that can be useful. Like administrate or active_admin. They can display data in a nice table. You can use filters and search on them. But it is basically all. The work with data can be a little easier, but still quite hard.

# Hero

It is time to introduce our hero. Blazer - a gem that makes business intelligence simple.

It allows you to execute SQL queries on your database from the web panel and visualize the data in a convenient and clear way. If you are not good at SQL you can ask your dev team to write some fundamental queries. Save them and use them on your own.

Another cool and useful blazer’s features are:

* Checking for anomalies in data - to let you know (by email for example) if there is something wrong with new data you are collecting
* Works with many data sources. You make your queries with SQL so it looks familiar and it works fine with most popular SQL-based databases (like Postgres, MySQL or SQL server). What is more interesting there is also beta support for MongoDB or ElasticSearch!


# Action

Let’s see blazer in action. You can install it in standard rails way by adding it to Gemfile

```
gem 'blazer'
```

Then run an install generator and migrations created by it:

```
rails g blazer:install
rake db:migrate
```

The last you have to do is mount blazer in config/routes.rb

```
mount Blazer::Engine, at: "blazer"
```

Then go to `/blazer` and take your first actions:
![Blazer preview](2017-01-31-blazer-a-great-tool-to-see-what-data-you-get/preview.png)

# See more

* Visit [https://blazerme.herokuapp.com](https://blazerme.herokuapp.com)  to play with blazer demo
* Visit [https://github.com/ankane/blazer](https://github.com/ankane/blazer) to learn more about gem itself



