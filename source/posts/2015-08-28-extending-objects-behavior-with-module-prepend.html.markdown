---
title: Extending Objects' Behavior With Module#prepend
author: karol
---

Ruby 2.0 came with some pretty useful features like lazy enumerators, keyword arguments, convention for converting to hash. There is also `Module#prepend`, which is not that commonly used, but there are some cases  where it really shines. Let's see what we can get from that feature then.READMORE

## What is Module#prepend?

`Module#prepend` alters the ancestors hierarchy in a way that the prepended module has the highest precedence. In other words, the method from prepended module is executed before the method you are directly calling. Consider the example below:

``` ruby
module A
  def print_stuff
    puts "I'm from module"
    super
  end
end

class B
  prepend A
  def print_stuff
    puts "I'm from class"
  end
end

B.new.print_stuff
# => I'm from module
# => I'm from class
```

As you can see, the method from module was executed as the first one. So how useful can it prove to be in real world?

## Unobtrusive core logic extensions

Imagine you have some service objects in your Rails application implementing the same interface, e.g. they all have process method accepting params argument:

``` ruby
class MyServiceObject
  def process(params)
    # perform some logic here
  end
end
```

And now you want to add some instrumentation (e.g. [with ActiveSupport](http://edgeguides.rubyonrails.org/active_support_instrumentation.html)) to your services layer to extract later some info about potential performance issues. Not really a problem, you can simply wrap you logic with one block:

``` ruby
class MyServiceObject
  def process(params)
    ActiveSupport::Notifications.instrument "MyServiceObject.process" do
      # do your custom stuff here
    end
  end
end
```

But adding it to every method call might be cumbersome. Thanks to `Module#prepend`, we can make it pretty painless. Let's create Instrumentable module for that purpose:

``` ruby
module Instrumentable
  def process(*args, **kwargs)
    ActiveSupport::Notifications.instrument "#{self.class.name}.process" do
       super
    end
  end
end
```

And you can refactor your service objects now:

``` ruby
class MyServiceObject
  prepend Instrumentable

  def process(params)
    # perform logic
  end
end
```

Nice! As the instrumentation is not really a core part of your business logic, you can create some kind of initializer where you would prepend Instrumentable to all classes being service objects. As a bonus, you won't need to remember about prepending module in new classes. Here's a quick idea how you may want to implement such initializer:

``` ruby
Dir["app/services/**/*.rb"].each do |service_object_file|
    service_object_file.gsub("app/services/", "").gsub(".rb", "").
      split("/").map(&:camelize).join("::").constantize.prepend(Instrumentable)
  end
```

What's happening here? We take all files from `app/services` directory (recursively from all subdirectories) and get the classes constants from the files' names respecting the namespace. And that's it! You don't need to remember about prepending Instrumentable module any more.

## Notable examples in the wild

`Module#prepend` is a pretty new feature, so it's not that commonly used. However, there are some nice examples in the wild showing how useful it is.

Remember `alias_method_chain` from Rails? Now you can forget about it, [`alias_method_chain` is deprecated in favor of `Module#prepend`](https://github.com/rails/rails/pull/19434), which makes the code much more understandable and cleaner.

It is also used in Lotus framework. Here's an example of very simple controller:

```ruby
class UserController
  include Lotus::Action

  def call(params)
    @user = User.find(params[:id])
  end
end
```

Looks nice, but it's supposed to be compatible with Rack middleware, how? Where's the env?

Such nice interface is possible thanks to `Module#prepend` again. Inside the `Lotus::Action` module the `Lotus::Action::Callable` module is being prepended and the entire magic happens inside the [call method](https://github.com/lotus/controller/blob/0.4.x/lib/lotus/action/callable.rb#L68) there:

``` ruby
def call(env)
  _rescue do
    @_env    = env
    @headers = ::Rack::Utils::HeaderHash.new(configuration.default_headers)
    @params  = self.class.params_class.new(@_env)
    super @params
  end
  finish
end
```

## Wrapping up

`Module#prepend` turns out to be an excellent addition to Ruby. There are not that many cases where you may need this feature, but when it happens so, it will make your code much more flexible and understandable.
