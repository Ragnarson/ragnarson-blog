---
title: Easy database migration using Taps(-taps)
author: wijet
shelly: true
tags: development
---

Migrating databases from one host to another can be a boring and time
consuming task. Usually you need to **make a database dump** on the host A,
**compress it**, **transfer it** to the host B, **uncompress it** and
finally **load it** into the database. Things get even more complicated
when we want to transfer database to a different database engine,
say from MySQL to PostgreSQL.

Fortunately there is taps. It's a tool for migrating databases. From this post you will learn how to use it, how it works and how to resolve its most common problems. READMORE


## Quick usage example

Let's assume we have a database named `gremlins` that we want to transfer
from MySQL on `src-host` to PostgreSQL on `dst-host`.

1. Before we begin make sure that at least major Ruby version is the same on both machines using ```ruby -v```. Otherwise you can stumble into problems with marshaling some data types.

2. Install **[taps-taps](https://rubygems.org/gems/taps-taps)** on both machines. I'll explain later <a href="/blog/2013/10/easy-database-migration-using-taps#why-taps-taps">why not the regular taps gem</a>.

   ```bash
   $ gem install taps-taps
   ```

3. Run taps server on the `src-host`. It uses HTTP basic for
   authentication, so that only you will be able to access it.
   Use a non-trivial password for security.

   ```bash
   $ taps server mysql://mysqluser:mysqlpass@localhost/gremlins user pass123
   ```

4. On the `dst-host` run the client to pull data and load it into
   a new database. You will need to specify user name and password set
   in the previous step.

   ```bash
   $ taps pull postgres://pguser:pgpass@localhost/gremlins http://user:pass123@src-host:5000
   ```

5. Wait for the import to complete. Progress will be printed on the console:

   ```bash
   Receiving schema
   Schema:          0% |                                          | ETA:  --:--:--
   Schema:          2% |                                          | ETA:  00:00:16
   Schema:          5% |==                                        | ETA:  00:00:15
   ...
   Schema:        100% |==========================================| Time: 00:00:16
   Receiving data
   34 tables, 6,800 records
   admins:        100% |==========================================| Time: 00:00:00
   ...
   versions:      100% |==========================================| Time: 00:00:00
   Resetting sequences
   ```

## How it works?

[Taps](https://github.com/ricardochimal/taps) creates temporary services
for migrating databases. In short it creates an HTTP server on the host from
which we want to transfer the database. On the destination host it provides
a client for pulling data from the server.

<img alt="Database migration" class="push--ends" width: "100%" src="/assets/posts/2013-10-24-easy-database-migration-using-taps/migration.png">

Main advantages:

 - Easy to use.
 - Database agnostic, for example we can migrate from SQLite to MySQL.
 - You don't need to expose your database to the outside world.

Disadvantages:

 - It can be slow on huge databases and tables without primary keys.
 - Foreign key constraints are not transferred.
 - Only works with the default database schema.

<h3 id="why-taps-taps">Last commit to taps was submitted a year ago. Does it even work?</h3>

Sure. Despite the fact that the [project](https://github.com/ricardochimal/taps)
looks abandoned, people are using it and submitting issues and pull
requests. I've [gathered bug-fixes](https://github.com/wijet/taps)
submitted by the community so that taps is usable again. It's available
as a gem under **taps-taps** name.

###  Nice, but my foreign keys constrains are gone.

One of Taps weaknesses is that it doesn't transfer foreign keys constrains.
To restore them we can use [immigrant](https://github.com/jenseng/immigrant)
gem which generates **all missing constrains** based on associations in
your Active Record models. To use it, add the gem to your Gemfile:

```ruby
# Gemfile
gem 'immigrant'
```

and run a generator to create a migration file:

```bash
$ rails generate immigration AddKeys
```

If you don't need all the constrains you can simply remove them from the
migration before running it.

## Using taps for migration from MySQL to PostgreSQL on Shelly

Taps becomes extremely useful when migrating to Shelly Cloud as
we don't support MySQL. This instruction assumes that your have
<a href="/documentation/quick_start">shelly gem properly set up</a>
and that your app is already deployed on Shelly.

1. First we create taps server on source host. This may be your
    production server, or your local machine with the most recent backup
    loaded.

  ```bash
  $ taps server mysql://mysqluser:mysqlpass@src-host/shop user pass
  ```

2. Then we create a tunnel to database on Shelly on our local machine:

   ```bash
   $ shelly database tunnel postgresql
   Connection details
   host:     localhost
   port:     9900
   database: cloud-name
   username: cloud-name
   password: 58cc478a414505a3cda6da810495a2
   ```

3. Finally we can transfer the database by running
   the command below on our local machine:

   ```bash
   $ taps pull postgres://cloud-name:58cc478a414505a3cda6da810495a2@localhost:9900/cloud-name http://user:pass@src-host:5000
   ```

   That's it! Should you have any questions regarding the migration you can
   contact <a href="/support">our support</a>.

As we can see taps provides pretty elegant solution to transferring
databases and it's certainly a gem worth knowing.
