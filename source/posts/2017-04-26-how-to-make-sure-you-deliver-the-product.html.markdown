---
title: How to make sure you deliver the product
author: dawid
cover_photo: cover.png
---

As developers we constantly try to improve our knowledge. We are trying to implement features where the code will be easy to maintain in the future. It is really important when we work on some long lasting, complex project. But should it be a priority when we work for a client with limited budget or tight deadline?

READMORE

There are many ideas about improving the codebase. This certainly helps us with learning new programming techniques. It’s really important to grow as a developer, but does it always mean that we should start with advanced implementations? Does it mean that better developer is the one who uses more design patterns? Let’s image you are joining a new startup team and you have 3 months to meet a deadline. You are responsible for creating an MVP to gain funding for further development. Are you starting with writing service objects for business logic? Are you trying to use database views to reduce database queries from the beginning? Of course, the answer is as always - it depends, but in reality, we should firstly focus on delivering, not on implementation details. In the end, the only thing that matters is if we managed to finish the MVP. A really good implementation with missing features has no value.

# The things that are important to focus on while working on an MVP

## Ask yourself what defines a good software

Your architecture and tools you will use depends on the complexity of a system you are building. Keep in mind that the good code is easy to understand and to change in the future. That’s it.

## Start with basic stuff

Before implementing rethink each feature. Try to find a way to make given thing as simple as possible. This also applies to your technologies. Don’t jump on some fancy javascript framework if you only need to dynamically show or hide some element. It’s really fine to start with the fat model and put all business logic there. Rails Way is good for you at this moment.

## Don’t be afraid to use scaffolds

In one of the recent projects we needed to implement simple admin panel. We just used scaffolds with basic bootstrap styling. It didn’t matter for admins now how it looks, they just needed a place where they could see all of the data. Scaffolds are the quickest way to have a fully working CRUD.

## Embrace feature specs

They are your biggest friend at the beginning. Even a simple spec that checks if some text is present on a given page can save you from introducing a regression. It has a great “hidden” value - it imitates user experience and will fail if there is any error on a page. And who cares if they are slow at this moment? A time for all of the unit testing will come.

## Don’t blame yourself for not the best code

For example iterating over collections to select some data instead of writing complex queries. It’s not a big deal right at the beginning, especially when your database is small. Don’t aim for ideal solution right now. Your software has to work and has to be delivered on time.

## Stick with the [Pareto Principle](http://theproactiveprogrammer.com/psychology/pareto-programming/)

It's really important to know when the feature is good enough to be deployed.

## Make sure the client knows we will refactor in the future

It’s your task to let your client know that at the beginning we can gain some development speed to help finish the MVP but it won’t be like that forever. We need to start refactoring at some time and he has to be aware of that. You will avoid unpleasant situations when he won’t be so happy with the time of implementing new features.

# The things to avoid from the beginning and are not hard to do

## Avoid using callback in models

They can be used for setting internal state, but never use them for some operation that is happening before/after given action. It can haunt you in the future.

## Try to leave as little as possible in controllers

I like short and clean controllers. They are responsible for accepting a request and calling proper service object. Then they should redirect or render proper thing based on the service object output. So if you have more than a simple CRUD action (for example sending mail after creating a user), it’s good to move it as a whole to the `User` class. It will be easier to refactor in the future.

# Summary

We, developers usually like to take challenging tasks. We like thinking about what is the best pattern to use in given situation, just to use our brains as much as possible. And I’m totally for it because this is a fascinating thing in being a professional developer. Writing the code itself is just our tool to create what we thought about. But in the end, someone is paying us to help him achieve his goals. We need to remember that we are here to help people with the growth of their businesses, not just to satisfy ourselves with writing clean code.
