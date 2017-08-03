---
title: How to manage front-end packages in Rails with Bower
author: bkzl
shelly: true
tags: development
---

[Bower](http://bower.io) is an open source software created by Twitter, which
simplifies dependencies management and updating of front-end packages (like
[gridism](http://cobyism.com/gridism/) or [normalize](http://necolas.github.io/normalize.css/)).
In general it is the same thing for HTML/CSS/JS what Bundler is for Ruby.
Not so long time ago version 1.0 has been released and the current stable version
is 1.2. Let's take a look at how to use it and integrate with a Rails app. READMORE

## Workflow

The easiest way to install Bower on your local machine is to use the [NPM manager
distributed with Node.js](http://nodejs.org/download/). Just run in terminal
`npm install -g bower`.

Basic workflow is really simple. In the application directory create
`bower.json` file. Next, add `name` key with your application code name and
`dependencies` key with hash as a value which is used to list packages to
install. Example file could look like this:

```javascript
{
  "name": "example",
  "dependencies": {
    "normalize-css": "*"
  }
}
```

Run `bower install`.

By default Bower downloads all packages to `bower_components` in the main
directory. If you want to add another one - edit `bower.json` and once again run
`bower install` or use shorthand and just run `bower install --save package_name`,
which will update the `bower.json` as well.

The second most used command is `bower update`, which updates all
packages to versions specified in the `bower.json` (or to the newest available if
you use `*` as a version indicator).

Last but not least, a command worth mentioning is `bower search`. Like its name suggest
it is used to find packages in the Bower registry. You can also search
the whole registry from [the web index](http://sindresorhus.com/bower-components/).

## Integration with Rails

Before you start using Bower in a Rails application you have to set up two things.

Firstly, you have to change the default path where packages are installed to
`vendor/assets`. To do this add in the application directory a `.bowerrc` file
with:

```javascript
{
  "directory": "vendor/assets/bower_components"
}
```

Secondly, you have to add this path to Rails configuration so packages will be
properly compiled. Modify your `application.rb` to contain the following line:

```ruby
config.assets.paths << Rails.root.join('vendor', 'assets', 'bower_components')
```

Finally, you are able to require packages in sprockets manifests. For example for
`normalize` it will look like this:

```css
/*
 *= require normalize-css/normalize
 */
```

The same thing can be achieved with [bower-rails gem](https://github.com/42dev/bower-rails/),
which additionally allows to install packages in different paths and uses very
similar DSL to Bundler to generate `bower.json`.

## Summary

There is one problematic thing with libraries which are not Bower ready. You
can still use it, but Bower just clone the whole package repository and store it
with your code. It can be fixed by adding `bower_components` to `.gitignore`
and installing packages during the deployment.

Another annoying fact is that JavaScript packages are mixed with CSS packages in
one directory. This can be solved using the `bower-rails` gem described above.

Bower simplifies day to day usage of external front-end packages in your
application. Managing them is a lot easier than performing it by hand. It is
also a cleaner solution than using Ruby gems only to wrap front-end files
which are often outdated.
