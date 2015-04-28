---
title: Problems with nil and how to avoid them
author: karol
published: false
---

Have you recently got an exception saying ``NoMethodError: undefined method `name' for nil:NilClass``? Most likely more than once. And how did you solve it? Maybe you used `try` and thought the problem is solved... until the same exception happened in a different place! Using methods like `try` is just treating symptoms, it doesn't even touch the real problem. Maybe the right question would be: why was it nil in the first place? Could it be avoided? Was the possibility of nil a desired behavior? And why at all is `nil` even a problem? Let's find out and investigate some usecases.READMORE

## Finding the origin of nil

Take a look at the code below and try to find the places where `nil` could occur:

```ruby
class SomeController
  def show
    @view_object = SomeViewObject.new(params)
  end
end
```

```ruby
class SomeViewObject
  attr_reader :email
  private     :email

  def initialize(params)
    @email = params[:emal]
  end

  def user
    @user ||= User.find_by(email: email)
  end

  def user_name
    user.name
  end
end
```

``` erb
# views
<%= @view_object.user_name %>
```

Running the above code will raise ``NoMethodError: undefined method `name' for nil:NilClass`` in the view. You would be probably confused why the `user` turned out to be `nil`. So the first place to look at would be the `user` method and the `find_by`. But why the user was `nil`? Was the `email` incorrect? Or maybe the `email` itself was a nil? Let's try to dig deeper. In constructor we extract email from `params` and it looks like there's a typo! Probably that was an issue. Or there was no `email` in the `params` hash. It took some time to debug why the user was nil and that was a trivial usecase. In complex logic that would be even worse.
Can such problems be avoided? Is it possible to catch nil in the exact place where it occurs? Fortunately, the answer is yes. You just need to:

## Use the right set of methods

Most occurences of nils in Rails applications originate from hashes and ActiveRecord finders returning `nil` where it was not supposed to be nil. When it comes to hashes, the fix is pretty simple: always use `Hash#fetch` instead of `Hash#[]` unless you have good reasons for it. How is `Hash#fetch` different? It works like `[]`, but raises `KeyError` if the specified key can't be found. You can also return a default value, raise custom error or whatever else you want; just pass it as a second argument or in a block:

``` ruby
params.fetch(:email, "default@email.com")
params.fetch(:email) { raise EmailNotFoundError }
```

You may always stick to using blocks instead of second argument, even for returning default values - if you have some expensive computation it will always be called in second argument, whereas in block it will be called when the key is not found.
What about ActiveRecord finders? There's a little inconsistency in Rails as `find` raises `ActiveRecord::RecordNotFound` if the record is not found, but `find_by` returns nil. It's not really a big deal if you already know it: just use bang equivalent:

``` ruby
User.find_by!(email: email)
```

Applying the right methods can save you a lot of time and makes it much easier to trace `nil`'s origin.
But what if the user may be nil and it's a desired behavior? In such case you can't use bang finders (unless you want to rescue from errors). Maybe adding a conditional in view would solve the problem:

``` erb
<% if @view_object.user %>
  <%= @view_object.user_name %>
<% else %>
  Anonymous user
<% end %>
```

You will avoid errors that way, but it's not really a great solution. It would be much better to use:

## The Null Object Pattern

Null Object is an object with some default behavior that implements the same interface as an other object that might be used in a given case.
Ok, cool, but how can we apply it to the example below? Let's start with the `user` method:

``` ruby
def user
  @user ||= User.find_by(email: email) || NullUser.new
end
```

And now we can implement `NullUser`:

``` ruby
class NullUser
  def name
    "Anonymous user"
  end
end
```

Last step is to refactor views:

``` erb
 <%= @view_object.user_name %>
```

No conditionals, no nils and the code looks beautiful and is bulletproof at the same time.
Let's add some more features and see what else we can achieve with The Null Object Pattern. How would we eg. handle comments for null user? If there's no user, there are probably no comments. Sounds like empty array:

``` ruby
class NullUser
  def name
    "Anonymous user"
  end

  def comments
    []
  end
end
```

No problems so far. But what happens if we would like to use methods like `where` or `order`, for example to display ten last comments? The best way would be to add `ten_last_comments` to `User` and implement the same method in `NullUser` which would still return an empty array. But let's imagine that for some reason we can't do that.

Since Rails 4 we can use `NullRelation` (Null Object pattern again) which implements the same interface as any other "real" relation. We just need to call `none` on `Comment`:

``` ruby
class NullUser
  def name
    "Anonymous user"
  end

  def comments
    Comment.none
  end
end
```

Now we can call whatever relation methods we want on null user's comments!
The Null Object pattern can be applied in many other usecases. Imagine have a service object where we create a user and want to log that the user has been created if the logger is provided. Without using Null Object pattern we would have something like that:

``` ruby
class User::Create
  attr_reader :logger
  private     :logger

  def initialize(logger: nil)
    @logger = logger
  end

  def process(params)
    User.create(params)
    logger.info("User created") if logger
  end
end
```

Doesn't really look that great. And we've got some serious problems if we forget about the `if` statement and the `logger` is nil. Let's try to make it bulletproof:

``` ruby
class User::Create
  attr_reader :logger
  private     :logger

  def initialize(logger: NullLogger.new)
    @logger = logger
  end

  def process(params)
    User.create(params)
    logger.info("User created")
  end

  class NullLogger
    def info(*)
    end
  end
end
```

Feels great - no conditionals, no possibility of accidental errors.

It might look that most of the cases are covered so far, but not really. Let's continue with user and the comments example. We have a blogging platform, a user added some comments and decides to cancel his/her account which causes User record to be deleted. What are the possible implications? We probably don't want to delete all the comments related to that user.

Does the comment without assigned user makes sense? Well, it might, we can use Null Object pattern - if there's no `user_id` persisted with comment - we would just return instance of NullUser. But what if it doesn't make sense in our domain to have a comment without a user, because we want to display e.g. an email in views, like:</p>

```erb
<%= @comment.author.email %>
```

and we forgot about implementing soft delete for users? We would have a nasty error because the user has been already deleted. The good news is that we can easily guard ourselves by:

## Using database constraints

The most common constraint for such problems (if you use a relational database like Postgres) is using `null: false` constraint on foreign keys. But is it enough? Not really, it just means that the `user_id` can't be nil, nothing protects us against deleting user and having a reference to the deleted record. Fortunately, we can use foreign key constraints, which are supported since Rails 4.2 (or you can just use gems like <a href="https://github.com/SchemaPlus/schema_plus" target="_blank">schema_plus</a> for that). With foreign keys it is impossible to delete a record which is referenced by other records and the protection is on database level, so there is no possiblity to bypass it. We would still have a bug, as the user who wants to delete own account would see that an error have occured, but at least we can easily fix it and nothing will break in comments section.

Let's imagine another usecase: we forgot about database constraints and soft delete. Futhermore, the user has already deleted the account. Can we do anything about it besides adding some conditionals in views or using `try`? Let's do a little refactoring and take a look at the views again:

``` erb
<%= @comment.author.email %>
```

The problem with this code is that it introduces some structural coupling (and makes <a href="http://en.wikipedia.org/wiki/Law_of_Demeter" target="_blank">Demeter</a> unhappy): to display the `email` we know that we need to ask the author of the comment for that. Do we really need to know everywhere that a comment belongs to an author? And what if we decide to denormalize data and add an `author_email` field to comments for performance or other reasons? We would need to change it everywhere. Why not use `comment.author_email` in the first place? Thanks to ActiveSupport, we can use:

## The Delegate Macro

The `delegate` macro offers a feature similar to <a href="http://ruby-doc.org/stdlib-2.0/libdoc/forwardable/rdoc/Forwardable.html" target="_blank">Forwardable</a>, but comes with some additional options and better syntax. We can easily delegate `email` to `author` with the following code:

``` ruby
class Comment < ActiveRecord::Base
  delegate :email, to: author, prefix: true, allow_nil: true
end
```

It will add `author_name` method (with `prefix`) which would return `nil` if `author` is not present. That way we reduced structural coupling and are guarded  `NoMethodError` from non-existent user.

## Bonus: persisting records with null objects

Sometimes you may come across a usecase, where you have an object which can be either a real model or a null object and want to assign it to other model and maybe even persist it. But you can't do it out-of-the-box, if you try to do something like:
`Comment.new(author: NullUser.new)`, you will get `ActiveRecord::AssociationTypeMismatch`. With persistence you will have even more problems. Fortunately, you can implement a simple concern to make ActiveRecord happy and simply treat the null object in persistence context as if it was blank. Here's an example:

``` ruby
module NullObjectPersistable
  extend ActiveSupport::Concern

  included do
    def self.mimics_persistence_from(real_model_class)
      @real_model_class = real_model_class
    end

    def self.real_model_class
      @real_model_class
    end

    def self.table_name
      @real_model_class.to_s.tableize
    end

    def self.primary_key
      "id"
    end
  end

  def real_model_class
    self.class.real_model_class
  end

  def id
  end

  def [](*)
  end

  def is_a?(klass)
    if klass == real_model_class
      true
    else
      super
    end
  end

  def destroyed?
    false
  end

  def new_record?
    false
  end

  def persisted?
    false
  end
end
```

And just use it in the `NullUser` class:

``` ruby
class NullUser
  include NullObjectPersistable

  mimics_persistence_from User
end
```

There's no magic here, it's just adding methods one by one to make ActiveRecord not raise any error and behave as we want it to.

## Wrapping up

Having accidental errors with `nil` is in most cases a symptom of bad design decisions, lack of some concepts in domain or not adding proper constraints to database. Fortunately, you can easily protect yourself from such problems with the discussed strategies.
