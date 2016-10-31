---
title: Introduction to fragment caching in Rails
author: marcin
cover_photo: cover.png
---

You’ve probably read or heard a lot that the two most difficult concepts in computer science are naming things and cache invalidation. The quote has appeared numerous times in books, blogs, and other programming sources in one form or another. While the only remedies for coming up with names are practicing a lot, being clear in our intentions or having a sudden epiphany (none of which are quick and simple), Rails tries to help us with the caching part as much as possible. Caching can significantly improve web application performance. This requires little additional code, especially if we have a large number of complex partial rendering.

READMORE

There is a lot of different things that we can cache in Rails: actions, SQL queries which are taken care of automatically for us, and page fragments. You can find an overview of all of those in [the official Rails guides](http://guides.rubyonrails.org/). Here we will focus on the fragment caching in views. We will discuss how it works, when it can be used and what are some gotchas or things we need to be mindful of.

We will also uncover the mystery of the cover for this post (that is unless you are already familiar with this concept).

### What exactly is fragment caching?

In order to help you understand fragment caching, let me first show an example structure that we will be working with throughout this article. This is a rather standard fragment of code that we can encounter in a typical Rails application. We have posts and these posts have multiple comments. We are displaying all of them on a page using appropriate partials:

```erb
# posts/show.html.erb

<h1><%= @post.title %></h1>
<p><%= @post.body %></h2>

<%= render @post.comments %>
```

The last part will look for `_comment.html.erb` partial and use it for displaying a collection of comments for this particular post. The partial is very simple as we will just use it as an example for caching:

```erb
# comments/_comment.html.erb

<p><%= comment.body %></p>
```

Whenever we visit a post page, Rails on the server side will fetch all the required objects from the database, render the views and send the requested page back to the browser. This may not be a problem in such a simple case, but when we have multiple nested partial views and multiple records (such as comments), then rendering the page for each request can take some time. It can be easily sped up with caching. This is especially useful if a page is requested by multiple users and is not likely to change very frequently.

When we turn the caching on, the application will do all the usual stuff for the first request and then save the completely rendered view to some kind of storage. It can be stored in memory, but usually Memcached or Redis will be used in the production environment. Then, whenever the same view is requested again, the application will check whether a version of it is already available in the cache. If it finds it there, then instead of getting data from the database, transforming it, rendering the views, etc. it will grab the saved version from the storage and send it to the browser. This will make our page faster and work for all the users visiting the page, not just the one who submitted the initial request. We just need to be aware of two things:

* A partial should not have elements that are specific to the context, e.g. to a particular user visiting the page. Therefore, any references to the `current_user` should be removed from the cached element. The partials should be built in a way that would work for multiple people without any changes.
* We need to be able to determine when something on the page has changed, like another comment was added. If we don’t let the application know that something has been updated, then the user would see the old stored version of the page. Fortunately, Rails makes this part easier for us and we will see an example a bit later.

Fragment caching is a lot more useful than full page caching, especially in complex applications. They are usually built with smaller components and it would not be productive to cache the entire pages. A change to one small part of the site would require re-rendering the full page and storing it again. That would negate the benefits of caching quite quickly. It is more useful and manageable just to target smaller bits.

### Turning on caching in development mode in Rails

Before we start with some examples, we need to turn on the caching in the development environment as it is turned off by default (though it is enabled in production). To do this in Rails 4, we need to change the appropriate option in the configuration settings.

```ruby
config.action_controller.perform_caching = true
```

Rails 5 made it quicker and easier to toggle. We can use a rake task, by typing `rails dev:cache` in our shell and pressing enter. To turn it off, we just use the same command once again.

### How fragment caching works in Rails

In order to cache some part of a view in Rails we surround it with a `cache` block, like the following example for comments:

```erb
<% cache do %>
  <p><%= comment.body %></p>
<% end %>
```

Everything between the `cache do … end` block will be cached and saved to a selected store. We need a way to properly identify the cached elements. Otherwise, the application would use the same cached item for each element in the collection and display the same comment over and over again. We also need a way to tell when something has changed and the version of the page we have in the cache is no longer the one that we want. We need to add some key for identification purposes. We can pass a second argument to the `cache` method. The key needs to be unique for each partial that is generated so that proper details are written and read from the cache. There is a column that is unique for objects in our database so we can use a part of the key. It is the object's id.

```erb
<% cache "comment-#{comment.id}" do %>
  <p><%= comment.body %></p>
<% end %>
```

Now every comment will be saved under `view/comment-id-of-the-comment` in the cache storage. This will work fine, but Rails will do a better job for us automatically if we pass the object instance to the method:

```erb
<% cache comment do %>
  <p><%= comment.body %></p>
<% end %>
```

Now when we refresh the page, Rails will parse the object mentioned after the `cache` method and write it under a folder like this:
`views/comments/1-20160820173406734241/dc2dabdcef7aee08968d3c45b8b9b0de`

We are getting something extra with the above code. The automatically assigned key contains object model name, id, updated_at timestamp and a hash value with some additional details (more on these a bit later). All that information is automatically taken from the object itself and we don’t need to do anything else. Now each cached comment will have its own unique identifier so Rails will know what is saved where and when. It will also get the required elements for us on the subsequent requests to this page.

The date part of the cache key is used when we update a comment - the timestamp will change and since Rails will not find the cached view with that key, it will write a new one. The last part in the above example is a hash value that holds information about the template used for the view. So when we add something to our comment partial (like an additional field or some new HTML code), it will know that something has changed, cache key is invalid and a new entry should be created. All this is done automatically for us.

The `cache` method accepts also an array if we want more details saved as a cache key. For example, we can add some string:

```erb
<% cache ["test", comment] do %>
```

This will result in the following folder structure: `views/test/comments/the-remaining-part-as-above`. This might be useful if we want to build more complex cache keys.

With the cache block in place when we access the page for the first time and look into the logs we will see that the rendered partials are being stored.

```ruby
Read fragment views/comments/1-20160820173406734241/dc2dabdcef7aee08968d3c45b8b9b0de (0.1ms)
Write fragment views/comments/1-20160820173406734241/dc2dabdcef7aee08968d3c45b8b9b0de (0.1ms)
Read fragment views/comments/2-20160820173412761671/dc2dabdcef7aee08968d3c45b8b9b0de (0.0ms)
Write fragment views/comments/2-20160820173412761671/dc2dabdcef7aee08968d3c45b8b9b0de (0.1ms)
Read fragment views/comments/3-20160820173416161439/dc2dabdcef7aee08968d3c45b8b9b0de (0.0ms)
Write fragment views/comments/3-20160820173416161439/dc2dabdcef7aee08968d3c45b8b9b0de (0.0ms)
```

Next time, they will be read from the cache.

```ruby
Read fragment views/comments/1-20160820173406734241/dc2dabdcef7aee08968d3c45b8b9b0de (0.0ms)
Read fragment views/comments/2-20160820173412761671/dc2dabdcef7aee08968d3c45b8b9b0de (0.0ms)
Read fragment views/comments/3-20160820173416161439/dc2dabdcef7aee08968d3c45b8b9b0de (0.0ms)
```

When we change something in the first comment, the cache for it will be rewritten. Other comments will still be grabbed from the cache.

```ruby
Read fragment views/comments/1-20160820173946997647/dc2dabdcef7aee08968d3c45b8b9b0de (0.0ms)
Write fragment views/comments/1-20160820173946997647/dc2dabdcef7aee08968d3c45b8b9b0de (0.0ms)
Read fragment views/comments/2-20160820173412761671/dc2dabdcef7aee08968d3c45b8b9b0de (0.1ms)
Read fragment views/comments/3-20160820173416161439/dc2dabdcef7aee08968d3c45b8b9b0de (0.0ms)
```

### Working with the nested partials

We have now cached our comments with one command. We would also like to cache the parent object, the post that holds the comments. First, we will add the `cache` keyword again, with the appropriate object as a key, `@post` in this example.

```erb
<% cache @post do %>
  <h1><%= @post.title %></h1>
  <p><%= @post.body %></h2>

  <%= render @post.comments %>
<% end %>
```

Great, now the post is saved to the cache with a proper key and everything should be awesome. The best part is that when we have the post and underlying comments cached, it will just check the parent element and grab everything from the cache (including comments), without hitting the database or re-rendering the comments:

```ruby
Started GET "/posts/1" for ::1 at 2016-08-20 19:41:53 +0200
Processing by PostsController#show as HTML
Parameters: {"id"=>"1"}
Post Load (0.1ms)  SELECT  "posts".* FROM "posts" WHERE "posts"."id" = ? LIMIT ?  [["id", 1], ["LIMIT", 1]]
Rendering posts/show.html.erb within layouts/application
Read fragment views/posts/1-20160820173300335185/d9d3e5734628bf0ed839791c0d9e965b (0.1ms)
Rendered posts/show.html.erb within layouts/application (3.6ms)
Completed 200 OK in 22ms (Views: 19.1ms | ActiveRecord: 0.1ms)
```

There is just one issue resulting from the above behavior. When you add a new comment or edit existing one for the cached post and then refresh the page it will still look like the old one. What happened?

Well, the post was saved to the cache with all the cached partials and with the appropriate key. When we changed a comment, this did not change the key for the parent post, so the application did not know that anything has changed. It just checked the key for the post first, found it and never bothered to compare anything beneath it. This is not good, but there is a quick fix for this.

We know that a part of a key for the cached elements contains information about the object update time. We just need a way to change the parent post’s `updated_at` date when we change something in the comments. In order to do this in Rails, we need to add `touch: true` for the comments to posts `belongs_to` association.

```ruby
# models/comment.rb
belongs_to :post, touch: true
```

Now, whenever we add new or update existing comment, `updated_at` for the parent post will be updated as well and cache key will expire. This will re-render the required partials and update those that need updating. Everything will be working as expected again.

You may be wondering what will happen if we change the template for the comment, though? Will the cached post know about it? Yes, it will. The hash value part of the cache key contains details about the parent partial as well as information about all the children partials so no work is required here. Everything will happen automatically.

The nested caching that we’ve done above, where one partial is cached inside of another, is called Russian doll caching (yay for the cover!). It gives us some benefits. Whenever one of the comments changes, the cache will be updated just for this one comment. The others will still be read from the cache as previously. Also when the parent object changes, only this object will be added to the cache, children comments will still be grabbed from the store.

There is one more thing that we can do to make our comment collection caching better. When you look at the logs, you can see that each partial for a comment is read individually. We can improve this with an additional option passed to the partial rendering. This will make reading from cache even faster. The option is `cached: true`.

```erb
<%= render @post.comments, cached: true %>
```

Now everything will be grabbed by Rails in one go. If anything needs updating, it will also be updated immediately and summary will be displayed in one line in the logs. Everything will work as previously but with a single trip to the cache instead of one per element.

```ruby
Rendered collection of comments/_comment.html.erb [8 / 9 cache hits] (2.6ms)
```

If Memcached is used as a storage, this will automatically make it use `get multi` instead of regular `get` to read all the record at once as well.

### Wrap up

Fragment caching is a great and easily accessible tool that we can use to quickly improve the performance of our applications. This is just an introductory post, but I wanted to give you an idea of how everything works and what tools are available in Rails out of the box. There are some other things to consider, like storage options for cached elements, more complex view fragments, other elements that can be cached etc. Still, I hope this article will familiarize you with the basics and encourage experimenting with caching in Rails.

I have also prepared a simple application for you to quickly test caching, check other available options or just play around with the code. [The application can be found here.](https://github.com/marcindrozd/fragment-caching-example)

<br>
##### Further reading:

* [http://guides.rubyonrails.org/caching_with_rails.html](http://guides.rubyonrails.org/caching_with_rails.html)
* [https://www.nateberkopec.com/2015/07/15/the-complete-guide-to-rails-caching.html](https://www.nateberkopec.com/2015/07/15/the-complete-guide-to-rails-caching.html)
