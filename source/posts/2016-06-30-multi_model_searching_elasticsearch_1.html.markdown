---
title: Multi-model searching using Elasticsearch vol. 1
author: dawid
cover_photo: cover.png
---

For one of our projects I had to do some complex searching. To cut a long story short, admin users wanted
a way to quickly search and assign one record of two models to another record. The client wanted searching
to happen with only one text input. After considering the complexity of searching by every possible column,
and the importance of speed, I decided to use [Elasticsearch](https://www.elastic.co/products/elasticsearch).
This was my first experience with this search engine and I would like to share my ideas about how to
implement it and organise the code. There is a lot of stuff to cover, so I’ll split it into 3 parts:
installing and indexing data, simple searching by multiple models and, finally, making searching
"more intelligent". Let’s see now how to get started with Elasticsearch.

READMORE

## TL;DR

I've created a sample app which will basically be the foundation for my blog posts. If you are
already familiar with Elasticsearch you can [check it out](https://github.com/Ragnarson/elastic_search_demo)
right away. It's a complete demo with some complex searching using nGrams.

## Installing Elasticsearch

If you are running the OS X operating system and use Homebrew, it’s as easy as this:

```sh
brew install elasticsearch
```

After installation, you will be asked if you want to have launchd start elasticsearch at login and I
advise you to follow these instructions. You won’t have to remember to start it every time you restart your computer.
Next, test if it really works by opening your browser and going to “localhost:9200” (9200 is the default port).
You should see some info about Elasticsearch including its version, etc.

Now it’s time to integrate it with a Rails application. It’s worth saying at this point that in the
past the most popular gems were Searchkick and Tire. They allow easy integration and offer some DSL
to work with but they are hard to customise if you want to use the full power of Elasticsearch. However,
there is a great alternative now - [Elasticsearch for Ruby](https://github.com/elastic/elasticsearch-ruby).
You will only need one gem so add it to your Gemfile and bundle:

```ruby
gem 'elasticsearch-model'
```

## Creating Indexes
What is an index in Elasticsearch? Well, it's just like a database in a relational database. To use
searching, you need to import data so, firstly, let’s create a module which will be included in our
models you want to search for.

```ruby
require "elasticsearch/model"

module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model

    after_commit do
      __elasticsearch__.index_document
    end
  end
end
```

Besides adding `include Elasticsearch::Model` to our models there is basically just one more important thing here:

- Every change to record should also be reflected in Elasticsearch and this can be achieved by
adding the `after_commit` callback which automatically indexes a given record after a change has been
committed in the database.

Let’s assume you want to search for User and House records. Include the `Searchable` concern in
both models. Please be aware that the Elasticsearch database is empty at the beginning and we have
to do an initial import of our existing data from the SQL database manually. In the `elasticsearch-model`
gem documentation, there is information that importing can be done simply by calling the `import`
method on the model. If your dataset is pretty large it can be really slow, and as we know, being
slow on production is always bad so let’s look at a better solution:

```ruby
module ElasticsearchDataImporter
  def self.import
    [User, House].each do |model_to_search|
      model_to_search.__elasticsearch__.create_index!(force: true)

      model_to_search.find_in_batches do |records|
        bulk_index(records, model_to_search)
      end
    end
  end

  def self.prepare_records(records)
    records.map do |record|
      {
        index: {
          _id: record.id,
          data: record.__elasticsearch__.as_indexed_json
        }
      }
    end
  end

  def self.bulk_index(records, model)
    model.__elasticsearch__.client.bulk({
      index: model.__elasticsearch__.index_name,
      type: model.__elasticsearch__.document_type,
      body: prepare_records(records)
    })
  end
end
```

This way we can do a bulk import. If you want to use it on production I strongly advise you to run
it in the background with a queue that can get stuck for some time. This way you won't need to worry
about how quickly the import is progressing and whether it’s blocking anything important.
Let’s take a step by step look at what it does:

- For each of the specified models it creates a new, empty index with the `create_index!` method

- It passes an array of no more than 1000 records to the `bulk_index` method

- The bulk_index method calls the Elasticsearch client.bulk API, which performs multiple operations in a single call

Now you can run it and, after data is imported, start searching. You can test if it works in your rails console, assuming you have data like:

```ruby
User.create(name: "John Doe",    city: "San Francisco")
User.create(name: "Lorem Ipsum", city: "San Andreas")
User.create(name: "John Rambo",  city: "New York")
```

Please take note that it will be automatically indexed with the `after_commit` callback.
The `Searchable` module includes the `search` method, so in your rails console it should look like this:  

```ruby
>> User.search("Rambo").results.total
=> 1
>> User.search("san").results.total
=> 2
>> User.search("john").results.total
=> 2
>> User.search("new york").results.total
=> 1
etc.
```

As you can see simple searching by the exact word is working. But nonetheless I’ve found this a little confusing:

```ruby
>> User.search("lorem york").results.total
=> 2
```

There is no `User` with the city `New York` and name `Lorem Ipsum`. It works like this because
Elasticsearch, by default, joins the query with the `OR` option, so we might say that every word
is treated like a separate query. For me, it seems a little confusing because, when typing this kind
of query, I expect to find users with the name `lorem` living in the city with the text `york`.
We'll look at how to change that in future posts.

## Wrapping up

So we got Elasticsearch running and we indexed our needed data, but that’s just the basic
configuration. Next time, we’ll see how we can do a multi-model search in a single command.
Let me know in the comments if you’ve got some other concepts or issues you would like to read about.

---

_As [Karel Minarik](http://www.karmi.cz) pointed out in the comments the Ruby integration is split
between 2 projects: The [low-level](https://github.com/elastic/elasticsearch-ruby) client which provides
a DSL for writing the search definitions and [Rails integration](https://github.com/elastic/elasticsearch-rails).
Basically by requiring the elasticsearch-model gem we are automatically using part of the Rails
integration. But I think that the low-level github repo is a good place to start, you can find there
all informations you need (also link to the Rails integration repository).
Also it turned out that we could simplify our importer by using the built in import method. It does
basically [the same](https://github.com/elastic/elasticsearch-rails/blob/master/elasticsearch-model/lib/elasticsearch/model/importing.rb#L122-L126)
thing._
