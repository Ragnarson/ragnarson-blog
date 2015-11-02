---
title: Managing assets with Rails Assets
author: grk
shelly: true
---

Up until recently, managing external CSS and JavaScript dependencies in Rails
apps was a big pain. Solutions varied from just checking the latest downloaded
version of a library into source control and forgetting about it to using Bower
to manage dependencies.

Take a look at your `vendor/assets` directory. How old are the libraries there?
How often do you remember to check for new versions? There could be some
serious bugs discovered and fixed, maybe even security issues resolved.

## Current approaches

One of the ideas of solving this problem is using the `*-rails` asset gems.
They are often unofficially maintained gems that re-package the original
library into a ruby gem. While we can't be sure they're up to date with
official releases, we gain a powerful tool that lets us know when newer
versions are available: `bundle outdated`.

Another way to manage assets is to use [bower](http://bower.io). It is a
package manager built using nodejs that is the defacto standard in the
front-end development world. Pretty much every library has a bower package,
and they're often maintained along with the library. That said, bower is not
without faults. First, the assets still need to be somehow added to the
app's directory when it's deployed. There are two ways to do this: either
fetch them on the development machine and add to source code, or add a hook
to your deployment process to install dependencies on each deploy.

## Enter Rails Assets

[Rails Assets](https://rails-assets.org) is a system designed to combine
the two approaches described above into one that is the best of both worlds.
From the outside, it acts as a gem server, with rubygems and bundler compatible
APIs, so it fits the normal workflow for ruby development and can be used
in a `Gemfile`. Under the hood, it fetches bower packages and automatically
converts them into gems.

Adding assets using Rails Assets is really simple:

First, add `https://rails-assets.org` as a source in your `Gemfile`:

```ruby
source 'https://rubygems.org'
source 'https://rails-assets.org'
```

Then, look up the package on the
[Rails Assets component list](https://rails-assets.org/components).
Most libraries will already be there, but if you can't find the one you need,
you should use the
[add component form](https://rails-assets.org/components/new) to request it.

Finally, add the gem to the Gemfile, with the `rails-assets-` prefix:

```ruby
gem "rails-assets-angular", "1.2.10"
```

Using this approach, you get the best of both worlds. The packages are easily
kept up to date with `bundle outdated`, installing gems is already included
in your deployment process, and the most recent version is available as soon
as the bower package gets updated.

<div class="island island--branded">
<h3>Free hosting for open source projects</h3>
Rails Assets is hosted on Shelly Cloud. If you need free hosting for your open
source project, <a href="mailto:support@shellycloud.com">let us know</a> and
we'll get in touch.
</div>
