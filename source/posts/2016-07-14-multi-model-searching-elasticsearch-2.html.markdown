---
title: Multi-model searching using Elasticsearch vol. 2
author: dawid
cover_photo: cover.png
---

In the [previous post](http://blog.ragnarson.com/2016/06/30/multi_model_searching_elasticsearch_1.html)
we saw how to install Elasticsearch and import data needed for searching. We also set up basic
searching for the `User` and `House` models. In the next post we will see how to improve searching
intelligence, but right now let’s take care of the main part of our functionality - multi model searching.

READMORE

## TL;DR

I've created a sample app which is a foundation for my blogposts. If you already are familiar with
Elasticsearch you can [check it](https://github.com/Ragnarson/elastic_search_demo) out right away.
It's a complete demo with some complex searching using nGrams.

## Multi-model searching

The [elasticserch-model](https://github.com/elastic/elasticsearch-rails/tree/master/elasticsearch-model)
gem provides an easy way to search within multiple models:

```ruby
Elasticsearch::Model.search(query_to_search, [User, House])
```

As you can see the `search` method needs 2 arguments: your query to search by and an array of models.
So without further ado let’s create a service object which will be responsible for searching:

```ruby
class Autocompleter < Struct.new(:query)
  MODELS_TO_SEARCH = [User, House]

  def self.call(query)
    new(query).call
  end

  def call
    results.map do |result|
      {
        hint: build_hint(result),
        record_type: result.class.name,
        record_id: result.id
      }
    end
  end

  private

  def results
    Elasticsearch::Model.search(query, MODELS_TO_SEARCH).records
  end

  def build_hint(record)
    case record.class.to_s
    when "User" then "Name: #{record.name}, City: #{record.city}"
    when "House" then "City: #{record.city}, Info: #{record.information}"
    end
  end
end
```

Calling `Autocompleter.call(“query”)` will return an array of hashes with matched data from both
models. If you are building some kind of form where user will be able to select some records
you basically can return 3 things from each result:

- Record type to know what kind of record user selected
- Record id to know which record of given type user selected
- Some kind of text describing given record which will be shown to a user. Let’s assume that
right now it should contain the most important columns from both models, like: `column_name: value, etc.`.
For example for User - `Name: “Dawid”, City: “Bialystok”`

## Presenting results

So let’s stop for a while and talk about possible solutions for creating the description in the `build_hint` method:

- Right now it just uses a `case` conditional and returns specific text for given class

```ruby
def build_hint(record)
  case record.class.to_s
  when "User" then "Name: #{record.name}, City: #{record.city}"
  when "House" then "City: #{record.city}, Info: #{record.information}"
  end
end
```

It just doesn’t feel right. It is polluting the `Autocompleter` class with the knowledge of how to
present results, it would be difficult to test in isolation and with some possible changes in the future in can look even worse.

- You could write some specific method in each model or even overwrite the `to_s` method. It looks
like a better solution, but such method in a class tends to be overused later. What if you think
you are doing a good job and use it in some other place? Then changing the way we present search
results would also affect different place in our app. Also it looks like moving too much logic to
a model and can introduce the [god object](https://en.wikipedia.org/wiki/God_object) anti-pattern.

- So what is the best way to get rid of conditionals? Let’s use polymorphism. So the `build_hint`
method will only delegate it to another service object, which is responsible only for presenting
results. Here’s the whole implementation:

```ruby
# In Autocompleter
def build_hint(record)
  BuildHint.call(record)
end

class BuildHint < Struct.new(:record)
  def self.call(record)
    new(record).call
  end

  def call
    result_builder.autocomplete_hint
  end

  private

  def result_builder
    "#{record.class}ResultBuilder".constantize.new(record)
  end
end

class ResultBuilderBase
  def initialize(record)
    @record = record
  end

  private

  attr_reader :record
end

class HouseResultBuilder < ResultBuilderBase
  def autocomplete_hint
    "City: #{record.city}, Info: #{record.information}"
  end
end

class UserResultBuilder < ResultBuilderBase
  def autocomplete_hint
    "Name: #{record.name}, City: #{record.city}"
  end
end
```

I really like this solution. Couple of small classes that are easy to read, understand and most
important part is that they are easy to test and change in the future without affecting anything else.

## Searching examples

As in the previous post let’s create some data:

```ruby
User.create(name: "John Doe", city: "San Francisco")
User.create(name: "John Rambo", city: "New York")

House.create(city: "New York", information: "Rambo’s house")
House.create(city: "Los Angeles", information: "Large villa")
```
And now it’s time to see how it works:

```ruby
Autocompleter.call("rambo")
=> [{:hint=>"City: New York, Info: Rambo’s house", :record_type=>"House", :record_id=>12},
{:hint=>"Name: John Rambo, City: New York", :record_type=>"User", :record_id=>16}]

Autocompleter.call("john")
=> [{:hint=>"Name: John Rambo, City: New York", :record_type=>"User", :record_id=>16},
{:hint=>"Name: John Doe, City: San Francisco", :record_type=>"User", :record_id=>14}]

Autocompleter.call("new york")
=> [{:hint=>"City: New York, Info: Rambo’s house", :record_type=>"House", :record_id=>12},
{:hint=>"Name: John Rambo, City: New York", :record_type=>"User", :record_id=>16}]
```

Pretty cool, right? Seems like everything is working as expected.

## Wrapping up

The most important functionality is already there. By now we got Elasticsearch running, importing
data automatically after each record update and made a multi-model search. In the next post
I’ll show you how you can improve the searching intelligence by specifying custom analyzers
when indexing and searching. Stay tuned and thanks for reading.


