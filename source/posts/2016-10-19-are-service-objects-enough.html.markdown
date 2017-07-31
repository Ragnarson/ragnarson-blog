---
title: Are service objects enough?
author: dawid
cover_photo: cover.png
tags: development
---

There have been a lot of buzz around service objects in Ruby community. It started some time ago and new articles about them popped up like mushrooms. I still think about myself as a “developer in progress” and I think it’s a good approach for all of us. We should always keep learning new stuff. For me, the so-called service objects were like a milestone. A lot of things started to look simpler with them. So how does the perfect implementation of service objects looks to me?

READMORE


## The perfect world

I assume that we all know what service objects are. If you are not familiar with them there is a ton of great articles about them. You can check [here](http://sporto.github.io/blog/2012/11/15/a-pattern-for-service-objects-in-rails/) or [here](https://blog.engineyard.com/2014/keeping-your-rails-controllers-dry-with-services) how to use them with Rails applications.


So we all know the main concepts: it should be a small class that does just one thing - some operation. It should be easy to test and not coupled your Rails application. But the problem is there are still a lot of questions about implementation details when using them in big projects.


What if we need to add some logic to existing service object? Should we create another service object and run it after the first one? Or should we process it within the initial one? What should we do if we want to get some data from service object after it does its job? Should we create some reader / method or return needed value from the main method? Should service objects even return something?


As you can see all these things can lead to long discussions in your pull requests. It’s good to think about these problems at the beginning.


Let’s assume we are implementing some registration functionality. We need to create a user and then send a welcome mail with some unique token inside.


## Are service objects enough?


So how can we implement it? There are basically 3 things we need to cover:

- Creating a new user record in the database
- Generating some unique token for created user
- Sending a welcome mail with the token inside


It’s worth splitting those tasks to separate and small service objects. But in reality, we are still talking about one action for the end user - registration. That's why it makes sense to introduce another layer of abstraction in our codebase - the commands. They are like glue to our service objects. The idea of it is: We call a command object from our controller and it can call many service objects.


## The return value


For command objects, I really like the approach of broadcasting events, like in [wisper](https://github.com/krisleech/wisper) gem. It solves one of the most important problems for me - the return value. Many times have I seen inconsistency in this area, for example:


```ruby
User::NotifyAdmins.call(params)
```
No return value. The service object is just responsible for sending email or message on Slack.

---


```ruby
user = User::Create.call(params)
...
if User::Contracts.call(user)
...
```
Returning some data from the main service object method. It can be some record or boolean value. We can just assume what it really is.

---


```ruby
user_creation = User::Create.new(params)
user_creation.call
user = user_creation.created_user
```
Explicitly returns a user with separate method / reader. All the examples above are just inconsistent. It can be confusing, harder to understand for new developers and even more difficult to test.

---

With the **wisper** gem we don’t return any value from calling the command itself. We just add listeners in controllers for every possible event we implement. Those events can include needed arguments when we need to get some data. Seems confusing? Let’s look at the example:


```ruby
class User::Register
  include Wisper::Publisher

  def call(email)
    return broadcast(:invalid) if email.blank?
    user = User.create!(email: email)
    broadcast(:ok, user.id)
  end
end

...
controller action
...

def create
  register_user = User::Register.new

  register_user.on(:invalid) do
    @user = User.new
    flash.now[:alert] = "Email address is missing"
    render :new
  end

  register_user.on(:ok) { |user_id| redirect_to user_path(user_id) }

  register_user.call(params[:email])
end
```


That's the first step of our implementation of the command object. I would put this class in the `app/commands/user` folder and move on to adding further things.


## Using service objects


So what about the so-called service objects? In my approach, they are still useful for doing one small thing and returning some value. In our example, they could generate  a unique token. A small class like:


```ruby
class User::GenerateToken
  def self.call(user)
    new(user).call
  end

  def initialize(user)
    @user = user
  end

  def call
    (generate and return token)
  end
end
```


is really easy to test in isolation and can be easily added to our command object. So the final implementation would look like:


```ruby
class User::Register
  include Wisper::Publisher

  def call(email)
    return broadcast(:invalid) if email.blank?

    user  = User.create!(email: email)
    token = User::GenerateToken.call(user)
    UserMailer.welcome(user.id, token).deliver_later

    broadcast(:ok, user.id)
  end
end
```


This allows us to extend or change our class in the future with little time. We could also broadcast more events with some other validation.


## The way to call commands


There is still one thing we could improve in my opinion. I’m not sold on the way we call command objects in our controllers. I suggest creating a base module for our commands:


```ruby
module BaseCommand
  extend ActiveSupport::Concern

  included do
    include Wisper::Publisher

    def self.call(*args)
      new(*args).tap { |obj| yield obj }.call
    end
  end
end
```


Now change the `User::Register` class to:


```ruby
class User::Register
  include BaseCommand

  def initialize(email)
    @email = email
  end

  def call
    return broadcast(:invalid) if email.blank?

    user  = User.create!(email: email)
    token = User::GenerateToken.call(user)
    UserMailer.welcome(user.id, token).deliver_later

    broadcast(:ok, user.id)
  end

  private

  attr_reader :email
end
```

This way we don’t need to instantiate command object and can use it in controllers like:

```ruby
def create
  User::Register.call(params[:email]) do |register_user|
    register_user.on(:invalid) do
      @user = User.new
      flash.now[:alert] = "Email address is missing"
      render :new
    end

    register_user.on(:ok) { |user_id| redirect_to user_path(user_id) }
  end
end
```


I think it looks awesome!


It’s also worth adding that there is a [wisper-rspec](https://github.com/krisleech/wisper-rspec) gem which helps with testing when using Rspec. You can test if command broadcasts proper event or stub them in requests specs.


## Wrapping up


If you want a clean architecture in your app, consider adding the command objects layer. There are places where you need to perform few operations one after another. If you could group them into one, logical action, you got a place for command. They should call service objects or perform some simple logic by itself. I also recommend you to try the [wisper](https://github.com/krisleech/wisper) library. It can clean your controllers and add some guidelines for other developers. It should help with keeping your code clean, easy to test and maintainable in the future.
