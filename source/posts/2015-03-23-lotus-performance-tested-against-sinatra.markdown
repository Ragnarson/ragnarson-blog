---
title: Lotus performance tested against Sinatra
author: smefju
shelly: true
---

Some time ago I heard about [Lotus][home]. A fresh Ruby framework for building web applications. It is created from stand-alone parts which are shipped as separated gems. This means that I am able to pick only the essential components for my project. The source code can be found on [github][source].

After a while, I began thinking about its performance. Finally, I decided to make a simple benchmark to check the following scenarios:

1. render a simple view using Slim and some helpers
1. render a view with the latest *Posts* from PostgreSQL database
1. create a new *Post* from request *params*

Initially, I considered Rails as an opponent, but this would be an unfair competition. Rails is a mature framework with a lot of built-in staff and Lotus does not have all these facilities. It was obvious that Rails would be significantly slower, so I decided to use [Sinatra][sinatra].

## Background

For stress tests, I used [wrk][wrk] tool with a basic lua script for performing a fake [POST request with params][wrk-post].

In both cases, Sinatra and Lotus, I used [Sequel][sequel] as a database adapter, PostgreSQL as a database, [Slim][slim] as a template engine and [Puma][puma] as an application web server. Source code can be found on github for both [Lotus][lotus-repo] and [Sinatra][sinatra-repo].

Puma was configured to use four threads in production environment:

```bash
 $ RACK_ENV=production puma \
    --threads 4:4 \
    --port 2500 \
    --preload \
    --quiet
```

All tests were performed using the following command:

```bash
wrk --connections 4 \
  --duration 30 \
  --threads 4 \
  http://localhost:2500/
```

with the optional `--script post.lua` argument for the last test. As you can see, `wrk` tries to keep 4 connections running for 30 seconds. The output will contain a number of handled requests with some additional statistics.

The database was cleared and seeded with the sample data (1000 *Posts*) before each test to avoid dummy queries:

```bash
 $ rake db:clean && rake db:seed
```

I ran code on the newest Ruby MRI 2.2.1, PostgreSQL 9.4.1 and the most recent versions of all used gems at the time.

## Test 1: Rendering a simple slim view using helpers

The first test was about rendering a view using:

1. [bootstrap][bootstrap] linked from the CDN for CSS stylesheets
1. gif from `public` directory
1. helpers for current date and time

Sinatra was able to handle around 42k requests in 30 seconds while Lotus took twice as many. This means that Lotus was able to process **2.8k** requests per second, while Sinatra processed "only" **1.4k**.

## Test 2: Rendering a view with the latest Posts from the database

The second test was about selecting the latest 15 *Posts* from the database, then rendering the view with the `title`, `body` and `created_at` fields for each *Post*.

The difference between Lotus and Sinatra was much lower than in the first test. Lotus served around **401** requests per second while Sinatra managed "only" **313**.

## Test 3: Creating a new Post from request params

The last test was about creating a new *Post* from given params (`title` and `body`), and redirecting to the `/` page.

In this case, Sinatra handled **589** requests per second and Lotus, again, was two times faster with a result of **1.1k** requests per second.

## "Benchmarks do not make sense..."

You may say that these kind of benchmarks do not make any sense because it is a bit like comparing an orange with an apple, but in my personal opinion, every benchmark says something about tools. It can also lead to some unexpected results. For example, I discovered that Lotus has some [problems with rendering partials][issue], and with iterating over an array of objects from the database, which results in poor performance. I think that it could be even faster after further investigation of these issues.

[home]:         http://lotusrb.org
[source]:       https://github.com/lotus/lotus
[slim]:         http://slim-lang.com
[sinatra]:      http://www.sinatrarb.com
[lotus-repo]:   https://github.com/smt116/lotus-sample-application/tree/blog-post/lotus-performance-tested-against-sinatra
[sinatra-repo]: https://github.com/smt116/sinatra-sample-application/tree/blog-post/lotus-performance-tested-against-sinatra
[sequel]:       https://github.com/jeremyevans/sequel
[puma]:         http://puma.io
[wrk]:          https://github.com/wg/wrk
[wrk-post]:     https://gist.github.com/smt116/acaf11f50eb46428b4f3
[bootstrap]:    http://getbootstrap.com
[issue]:        https://github.com/lotus/lotus/issues/185
