---
title: "Database Views in Rails with Scenic"
author: krzysztof
cover_photo: cover.png
---

This article describes how database views can be a solution for an application with complex relationships and how Scenic gem simplifies the task of implementing those views in your Rails application.

READMORE

# The App

The app we are currently working on is a customized management platform for software development agencies. Clients may have multiple projects, projects may have multiple developers, designers etc. The tree branches out pretty broadly in terms of a developer to project assignment as this is the core feature of the application.

# The Problem

Our client asked for a view representing people’s availability for assignment to a new project. An employee is perceived as available if he meets any of the following criteria:

- is currently on an internal project
- is in an external project that ends in less than one month in the future
- is not assigned to any project

The database structure in terms of user-to-project relation looks as follows:
<figure>
  ![Database Structure](2016-12-09-database-views-in-rails-with-scenic/db_schema.png)
</figure>

# Possible solutions

## Combined Scopes

The first solution that came to us was to use multiple scopes and combine them together. This would be the most “rails way” approach. The drawback of the solution turned out to be the level of complexity. The building scopes would need to be scattered across the user and the project scopes. The query built by ActiveRecord would be far from optimal and simple. As a result, the code could be harder to understand and maintain.

## Flag record on the users table

Another solution was to implement a flag that is going to store information if a user is available or not. The drawback of the solution would be the need to maintain a quite complicated callback structure that is going to update the user model every time the end_date changes.

The `end_date` stands for the end of an assignment for a developer. Not always the project end date is the same as the developer’s assignment end date. There are situations where a developer may be assigned only for a short period of time to complete a task or to help the team to meet a deadline.

The implementation would not be complicated but we want to avoid callbacks as they are difficult to maintain and blur the transparency of the database - model layer flow.

## Database Views

The final solution that we came up with was to use database views to join multiple queries. This seemed to fit all our needs, as there would be a single query executed only if needed and there would be no callbacks required. A database view works like a “virtual” table and can be joined with other “physical” tables. We agreed that this solution was the most fitting and we gave it a shot.

# Implementation

We’ve searched for a ready-made gem which implements an interface for managing database views and we’ve stumbled upon the Scenic gem from Thoughtbot:

[https://github.com/thoughtbot/scenic](https://github.com/thoughtbot/scenic)

The gem had everything we needed and the implementation was somehow natural with Rails.
The view creation is very similar to a schema update and is triggered by `db:migrate`. Another great feature is that any created view works with ActiveRecord as a regular model and comes with all its native features. Scenic turned out be a perfect fit for our scenario.  

## Installation:

Add `scenic` to your Gemifle

Run:
`bundle install`

To generate a view simply run:

`rails generate scenic:view view_name`

In our case, the view_name was `available_people`

The last command created a new empty schema migration file in the following path:
`~/app/db/views/available_people_v01.sql`

Contents of our available_people_v01.sql file:

```sql
SELECT users.id FROM users
JOIN assignments on users.id = assignments.user_id
JOIN projects on assignments.project_id = projects.id                      
WHERE assignments.end_date < (now() + '1 month'::interval) AND projects.internal = false

UNION

SELECT users.id FROM users
JOIN assignments on users.id = assignments.user_id
JOIN projects on assignments.project_id = projects.id
WHERE projects.internal = true AND (assignments.end_date > now() OR assignments.end_date is NULL)

UNION

SELECT users.id FROM users                                  
LEFT JOIN assignments on users.id = assignments.user_id
WHERE assignments is NULL;
```

We can access the view by using a simple sql query in a model or a scope. An advantage of this solution is putting the workload in the DB and keeping the implementation in the model to a bare minimum.

After the file was edited and filled in with our queries we were able to apply the view to our database by simply running:

`rake db:migrate`

The process for creating a view is similar to creating new table.

## The model layer

We had two options to access the data from the view in the model. We could create a new model in Rails or use a direct query from the `User` model. In this case, we only needed to see if a given user_id was present in our view and scope the user model by it.

```ruby
# app/models/user.rb
scope :available, -> { joins("JOIN available_people on users.id = available_people.id") }
```

Now, we could use our database view with the `User` model. We can always create a model for the database view in case we need to do any data manipulation on it.

# Conclusions

Scenic has much more to offer and it’s a very useful tool to have in your toolbox. I can highly recommend getting acquainted with it and utilise database views in your everyday backend work.
