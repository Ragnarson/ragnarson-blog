---
title: Test the things that matter
author: dawid
cover_photo: cover.png
---

Testing your application is a crucial thing to ensure that everything is working as expected. It gives you a quick feedback if the new feature can be shipped and you didn’t introduce any regression. It’s pretty much an integral part of development. If you like the TDD technique it means that you write your tests even before writing the actual code. But you have to remember that your tests are also an important part of your codebase and you have to take care of them. They should be easy to understand and modify in the future. It’s also important to isolate your tests as much as possible and check things that really matter. Let’s look at some example.

READMORE

# Imaginary example

Let's follow some imaginary example. It's not that far away from our normal, typical workflow. While implementing a new feature you realize that its parts can be reused and are likely to be changed many times over the time. So let's assume we have a service object that is run after `User` registers in our application. It should create a User record and return some super secret token. The implementation details of generating the token are not really important. It could look like this:

```ruby
class User::Register
  def call
    User.create!(email: email)
    generate_super_secret_token(email)
  end

  private

  def generate_super_secret_token(email)
    # ...
  end
end
```

We also write tests for this class:

```ruby
it { expect { subject.call }.to change(User, :count).by(1) }
it { expect(subject.call).to eq("TOP SECRET") }
```

# Making a small mistake

It all works great, but now we have to reuse the generation of the token. So we move this logic into its own class and change our service object to:

```ruby
class User::Register
  def call
    User.create!(email: email)
    User::GenerateToken(email)
  end
end
```

The `User::GenerateToken` can be reused in as many places as needed. We can move the code around, write specs like the one existing before and think that our task is finished. And this is that small mistake, which could haunt us in the future. Specs are green, our tests checks if the correct token was created, so what could be the problem?

# Changing the token generation

Now you have to change the algorithm for token generation. You changed it in the `User::GenerateToken` class. Now suddenly every spec for the class that uses it is failing. What has happened? It turns out that now you have to modify every spec for classes that use that service object. You could easily avoid it by refactoring also your specs when creating the `User::GenerateToken` class. It could look like that:

```ruby
before { allow(User::GenerateToken).to receive(:call) { "TOP SECRET" } }

it { expect { subject.call }.to change(User, :count).by(1) }
it { expect(subject.call).to eq("TOP SECRET") }
```

A simple stub gives us 3 really important wins here:

- It ensures we won’t need to modify this code in case of internal changes of the `User::GenerateToken`
- It isolates our tests, meaning that they don’t rely on any other parts of the application. It also makes it easy to find the cause of a failed test
- It doesn’t even call this code, but automatically returns the "TOP SECRET" text when it is called. This way we can really speed up our tests and don’t run the same code over and over again in multiple places.

This may seem like a trivial example, but it’s really important to look at your specs like that and isolate them. This example is written more like a pseudocode just to show you the main benefits of presented solution. I [don’t like](https://blog.ragnarson.com/2016/10/19/are-service-objects-enough.html) returning any value from service objects and this spec could just use a mock:

```ruby
expect(User::GenerateToken).to receive(:call).with(email)
```

# Testing the right way

I would also like to present my "ideal way" of testing new features. We can divide it into 3 groups:

## Feature specs

You should do a "Happy path" with this spec. The Happy path is pretty much the simplest optimistic scenario of a new feature. Feature specs do actual requests and go through the whole application stack. They can work with Javascript with [poltergeist](https://github.com/teampoltergeist/poltergeist) and mimic the user interaction with the browser. You can use a very popular [capybara](https://github.com/teamcapybara/capybara) gem, for example, to fill in form fields and submit them. Please keep in mind that your final expectations shouldn't check for changes in the database. They should rather verify if the user sees correct data on the page. This way you are actually testing the user’s behavior and that's what feature specs are for. Keep in mind that you shouldn't overuse them, because they are the slowest ones.

## Request specs

Since Rails 5 there is a strong [recommendation](https://github.com/rails/rails/issues/18950) to discard controller specs and go with request specs. They are really similar in terms of writing them. The main difference is that controller specs were more like unit tests for the controller classes. No real request was made, so, in reality, we couldn't assume that everything works the same when all layers of our app are involved. Request specs actually hit your endpoints. I like to use them for checking if commands or service objects are called with proper arguments. Also if the user is redirected to proper endpoint after certain outcome. Since I use controllers mostly for calling service objects and rendering/redirecting pretty much no business logic is tested here.

## Unit specs

Where the real testing happens. Pretty much every method on your classes should be tested. The main thing is to test your business logic, which is good to keep in separate service objects. But don't forget about your models. It doesn't really matter if you use scopes or you like query objects. Also, it is not important if you use validations in models or use form objects. You should test it all thoroughly. Unit tests are the fastest ones, remember to try to isolate them as much as possible. It also doesn't matter if you use dependency injection or not. Stub all calls to other classes.

# Wrapping up

Isolate your tests. With this approach, I think you can test the most important things. Could it be improved? Surely, but in the real world, we often work on quickly evolving projects. It's important to make good enough test coverage and move on to next task. I don't really see a point in testing for example associations or creating view specs. They could help us finding some regression, but writing and maintaining them isn't worth it in most cases.
