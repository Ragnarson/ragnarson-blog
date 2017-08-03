---
title: The cost of using Ruby Gems
author: jonasz
tags: development
---

## Gems are great...

Gems are a superb tool for every Rubyist. They can help you rapidly
implement complex solutions in your applications without having to
reinvent the wheel.READMORE

The very rich ecosystem of gems can provide you with basically any
functionality you could think of: authorization, admin panels,
pagination – you name it.

## ...but not when overused

One could think that you can't go wrong with something as useful as
gems. Yet, careless addition of new gems might be harmful in the long
run.

Adding too many gems to your application might cause several problems.
Some of them are more immediate while others might show up later on in
application's lifecycle.

# To code or not to code

One of the reasons to use gems is to not reinvent the wheel – someone
already wrote some code which tackles the problem at hand. In some cases
it's instead worth to code the functionality yourself.

One case is when the needed functionality is simple enough that it won't
take you more than 30-60 minutes to create.

Other case would be when the solution needed in the project is very
specific and no gem would be able solve it without modifications.

# Code bloat

With each new gem added to your application, your application's process
will grow larger and larger, consuming more server resources and slowing
response and startup times.

Each gem also brings it's dependencies to your application, making your
application's size grow faster than you might expect.

# Magic!

Gems just work and you don't really know how in order to use them. It's
often enough when you're on tight deadlines in your projects.

But if you strive to be a better programmer and really understand the
code you're writing, it's a good idea to take a look at how gems you use
work.

High reliance on gems might also make getting familiar with the project
more difficult, especially if someone isn't used to gems included in the
project.

# Update hell

Updating gems sounds easy – but when you're using many gems with a lot
of dependencies it might become a nightmare.

Different gems, depending on their update schedules, might become
incompatible with one another after some time, due to being dependent on
different versions of the same gems.

Monkey patching those incompatibilities or trying to replace the
incompatible gems – either by other gems or own code – is something most
developers would prefer to avoid.

# Other incompatibilities

Except already mentioned incompatibilities due to gem dependencies some
gems might be just incompatible due to similar functionality they
provide. If the code in those gems gets in each other's way those gems
probably won't work well together.

Like before, you might be able to find workarounds to make them work,
but it's best to just avoid them if possible.

# Conclusion

Gems are a great tool – but like every tool, they can be used
irresponsibly.

If you need some basic guidelines, you might try answering some
questions before adding a new gem to your app.

Does the gem you want to add:

- Provide functionality simple enough to be implemented without a gem?
- Meet all the specific functionality requirements needed by the application?
- Bring overhead worth functionality it provides?
- Have an active maintainer?

I'm not saying you should abandon using gems – only to be more conscious
about it.
