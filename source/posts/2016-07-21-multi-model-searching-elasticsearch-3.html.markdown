---
title: Multi-model searching using Elasticsearch vol. 3
author: dawid
cover_photo: cover.png
---

This is a final part of the series about [Elasticsearch](https://www.elastic.co/products/elasticsearch).
We already covered [installing](http://blog.ragnarson.com/2016/06/30/multi_model_searching_elasticsearch_1.html)
and [multi model searching](http://blog.ragnarson.com/2016/07/14/multi-model-searching-elasticsearch-2.html).
Now it’s time to talk about some of the more complicated stuff and try to improve the searching intelligence. Let’s dive in.

READMORE

---

This a part of a three post series:

1. [Part 1 - basic setup](http://blog.ragnarson.com/2016/06/30/multi_model_searching_elasticsearch_1.html)

2. [Part 2 - multi model searching](http://blog.ragnarson.com/2016/07/14/multi-model-searching-elasticsearch-2.html)

3. [Part 3 - improving searching intelligence](http://blog.ragnarson.com/2016/07/21/multi-model-searching-elasticsearch-3.html)

---

## TL;DR

I've created a sample app which is a foundation for my blog posts. If you already are familiar with
Elasticsearch you can [check it](https://github.com/Ragnarson/elastic_search_demo) right away.
It's a complete demo with some complex searching using nGrams. All of the code examples can be found there.

## Requirements

Firstly let’s do a quick round-up of how our searching is working right now:

- We use the `Autocompleter` service object to search by multiple models
- We can search by any column, but it has to be an exact match of the whole word. So we won’t
find `John` if we would search by `Jo` or `ohn` or any other part of the word.
- We are searching with the default Elasticsearch `or` operator. That means that searching by
`John York` will return all of the records with `John` or `York` somewhere in the columns. In simple words we will get all users from `New York` and all users with name `John`, no matter what city the live in.

So it all works great, but let’s assume we just received a new ticket with some new requirements, like:

- Every word should narrow results, not expand them
- If found, the `House` records should be always on the top of the results list
- Searching should return max 50 results
- Searching should be allowed by any part of any column, not only by the exact match of the whole word

All of those things would strongly improve searching intelligence and help users to find what they
need faster. This is the place where Elasticsearch shows its full power. We can achieve all of
these with little tweaks during indexing and searching.

## Custom searching configuration

To make first 3 points from requirements list work you need to add custom searching definition.
Add this private method to the `Autocompleter` class:

```ruby
def search_query
  {
    "size": 50,
    "query": {
      "function_score": {
        "query": {
          "match": {
            "_all": {
              "query": query,
              "operator": "and",
            }
          }
        },
        "functions": [
          {
            "filter": { "term": { "_type": "house" }},
            "weight": 5_000
          }
        ]
      }
    }
  }
end
```

To use it when searching, change the `results` method to:

```ruby
def results
  Elasticsearch::Model.search(search_query, MODELS_TO_SEARCH).records
end
```

Let’s see which parts are the most important here:

- You can specify the `size` option. Pretty self-explanatory
- To narrow results and get rid of the confusing `or` operator described with the `John York`
example above just specify the `"operator": "and"` option. Please take a look at it carefully,
you can even read it loud. The query should `match` `_all` columns with `query` with the `operator: and`.
I like how it is constructed, just by reading it loud you can understand what is going on
- Elasticsearch uses its own algorithm to calculate the searching score and sort results.
To tweak it you can use the `function_score` and specify a custom weight for some term. In this
example the `_type: house` will gain a big boost in score thanks to the big weight and always be returned before other types

## Searching by parts of words

So far so good, but we still need to improve in my opinion the most important thing. Again with our
example, users want to quickly type `joh yor` to find all of the Johns from New York. I think this
is the most important improvement from the user perspective, but it’s also the most complicated
one to do. You need to learn about nGrams and how using them when indexing data can help.

In simple words with nGrams we can get more matches when searching. Every word is split into tokens,
which are then associated with given record. Let’s see some example to fully understand
what that means. For example a word "john" would be split into:

```
1-gram tokens ["j", "o", "h", "n"]
2-gram tokens ["jo", "oh", "hn"]
3-gram tokens ["joh", "ohn"]
4-gram token  ["john"]
```

It allows us to pass any of these tokens to search method and get results including the `john` word.
So how to implement it? There is a lot of information in the official documentation about nGrams and
how to use them, but I would like to share with you a post which really helped me. Sloan Ahrens did a great
job [describing](https://qbox.io/blog/multi-field-partial-word-autocomplete-in-elasticsearch-using-ngrams)
what we are trying to achieve and my solution is highly inspired by his suggestions. I did simplify
it a little. Just add it to your `Searchable` module, inside the included block:

```ruby
settings analysis: {
  filter: {
    ngram_filter: {
      type: "nGram",
      min_gram: 2,
      max_gram: 20
    }
  },
  analyzer: {
    ngram_analyzer: {
      type: "custom",
      tokenizer: "standard",
      filter: [
        "lowercase",
        "asciifolding",
        "ngram_filter"
      ]
    },
    whitespace_analyzer: {
      type: "custom",
      tokenizer: "whitespace",
      filter: [
        "lowercase",
        "asciifolding"
      ]
    }
  }
} do
  mappings _all: {
    type: "string",
    analyzer: "ngram_analyzer",
    search_analyzer: "whitespace_analyzer"
  }
end
```

If it scares you don’t worry. It looks complicated but it’s just some concept of analyzers which are
applied when indexing and searching is done. The most important thing is that is creates a `nGram`
filter with the `min_gram` set to 2. This allows us to search by parts (from 2 chars long) of
any field, not only by exact match of the whole word.

I’m not gonna delve into details for this configuration. Sloan Ahren’s blog post is a great
place to find detailed explanation what is going on here and I really advise you to read it.

Please remember that when you change anything the way data is indexed, you need to import it once more. Run:

```ruby
ElasticsearchDataImporter.import
```
and you are good to go.

## Searching examples

As always let’s finish with some examples. Create some data:

```ruby
User.create(name: "John Doe", city: "San Francisco")
User.create(name: "John Rambo", city: "New York")

House.create(city: "New York", information: "Rambo’s house")
House.create(city: "Los Angeles", information: "Large villa")
```

And test our final version:

```ruby
Autocompleter.call("joh ram ork")

=> [{:hint=>"Name: John Rambo, City: New York", :record_type=>"User", :record_id=>16}]

Autocompleter.call("los ang villa")

=> [{:hint=>"City: Los Angeles, Information: Large villa", :record_type=>"House", :record_id=>13}]
```

Awesome! And just to make sure that confusing `or` operator is no longer applied:

```ruby
Autocompleter.call("los ange rambo")
=> []
```

Looks like John Rambo doesn’t have any houses in Los Angeles.

## Wrapping up

Elasticsearch is great but it has a steep learning curve. There are a lot of new informations, some
new concepts about indexing, analyzers, tokens, searching, etc. This series is just a small example
what can be achieved and how you can integrate it with your Rails application. If you want to learn
Elasticsearch I really advise you to spent some time on reading documentation and more blog posts.
To use the full power of this search engine you need to fully understand how it works. Also
you can check a working [demo](https://github.com/Ragnarson/elastic_search_demo) with all of the code from my series about Elasticsearch.
