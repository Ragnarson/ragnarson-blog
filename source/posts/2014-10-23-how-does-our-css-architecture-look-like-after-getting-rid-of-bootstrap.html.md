---
title: How does our CSS architecture look like after getting rid of Bootstrap
author: bkzl
shelly: true
tags: development
---

In summer, several well-known companies such as [GitHub][1], [CodePen][2] or [Buffer][3] have published blog posts about how the CSS architecture is designed in their applications.

Due to the fact that in September we finished transferring Shelly Cloud from Twitter Bootstrap (from version 2.3.2) to the styles developed by us and based on the Inuit framework, I wanted to share the experience that we've gained doing this. READMORE

*If you haven't heard of the Inuit framework before, please check [my previous blog post][4] where I described it.*

## Why we dropped Bootstrap

From the very beginning, when we started creating Shelly Cloud, for CSS we used one of the first publicly available versions of Bootstrap. Bootstrap was very limited at that time, especially looking through the prism of what it offers now. Moreover, we wrote a lot of CSS by ourselves and what's worse, actually none of us ever really took writing styles seriously. It affected us later during the development. We were able to regularly update Bootstrap to the last second release - 2.3.2, but the strong connection between the framework and our CSS made upgrade to 3.0 too time-consuming and complicated.

We did not touch our CSS too much until the discovery of the Inuit framework. Inuit in no way dictates the design of the application. It suggests a structure and offers a low-level CSS modules that can easily be attached to your own code. We decided to replace Bootstrap with Inuit in small steps.

It wasn't nearly as difficult as you might think. We started with transferring all the current assets to a gem. A good idea is to configure Bundler to use the gem from the local machine. It's very convenient when we often edit the library which is directly linked with the application. You can do that like here:

```ruby
# Gemfile
gem 'shelly-ui', github: 'shellycloud/shelly-ui', branch: 'master'
```

```shell
# In your terminal
$ bundle config local.shelly-ui ~/code/shellycloud/shelly-ui
```

From the other things, we had a separate layout that used only new styles, and an additional flag in the controllers which we changed when view was prepared for the new version. An important thing that's worth mentioning is that when a page was ready, we immediately deploy it to the production environment. It was evident that it differed slightly from the rest, but in the long-term we've avoided two things - maintaining two versions of CSS simultaneously and merging a huge branch at the end of the update. In addition, the order which we have followed when rebuilding views was not accidental. We started from the simplest static pages, then we replace the more complex ones, e.g. pricing, and we finished with the panel that's available to users upon logging in.

## Current CSS architecture

Before I start to write about CSS, I would like to add that for HTML templates we are using Slim, whose syntax is for us much more convenient and clearer than erb or HAML. We also adopted two conventions:

To write divs in the following way:

```slim
-# good
div class="box"
  | ...

-# bad
.box
  | ...
```

To use interpolation when text was mixed with other HTML elements:

```slim
-# good
p
  | Lorem <strong>ipsum</strong> #{link_to 'dolor sit', '#'} amet

-# bad
p
  ' Lorem
  strong ipsum
  = link_to 'dolor sit', '#'
  |  amet
```

As a CSS preprocessor we use SASS in conjunction with [Autoprefixer][5] gem. I cannot imagine not using a preprocessor. The ability to define things such as variables, functions or mixins drastically simplifies writing and maintaining code. Moreover, thanks to the autoprefixer, we don't have to worry about vendor prefixes in CSS rules.

To manage external libraries we use a free [Rails Assets][6] service. This gives us access to the entire [Bower Directory][14], actually without any additional settings. We can simply write all the necessary libraries like Inuit, Angular or [sugar.js][7] right in the Gemfile.

For the class names we use [a simplified version of the BEM methodology][8], trying to use no more than [one/two modifiers per element][9].

If we need to refer to an element in JavaScript, we always add an additional class with `js-` prefix, so that we avoid the problem of something suddenly stopping to work after removing a class:

```slim
-# good
div class="flash js-flash"
  | ...
coffee:
  $('.js-flash')

-# bad
div class="flash"
  | ...
coffee:
  $('.flash')
```

We don't use IDs in HTML at all, the only exception being anchors in the table of contents of the articles.

Our directory structure is similar to that proposed by Inuit:

```
generic/
  _normalize.sass
  _functions.sass
  ...
base/
  _form.sass
  _table.sass
  ...
objects/
  _box.sass
  _navbar.sass
  ...
inbox/
  _shame.sass
  _new-landing.sass
  ...
_settings.sass
application.css.sass
```

In `generic` we keep the lowest level styles such as definitions of our own functions, mixins or animations.

The `base` contains CSS related to HTML elements, e.g. global settings for tables, lists and forms.

The components defined by us, e.g. navbar, flash or box, we keep in `objects`.

The last directory, `inbox`, has a special function to store the code that we know needs refactoring or is written by people who haven't dealt with front-end development before.

We have defined all font sizes, margins and colors as variables in `_settings.sass`. We never use absolute values in the code.

If we have a situation that, e.g., a color exists only in one particular case, we use the `lighten()` and `darken()`:

```sass
// good
.flash--success
  color: $color-positive
  background-color: lighten($color-positive, 30%)

// bad
.flash--success
  color: #5cb85c
  background-color: #346a34
```

For paddings and margins, we have prepared functions such as `quarter()` or `double()` that return a multiple of the specified variable:

```sass
// good
.box--narrow
  padding: halve($base-spacing-unit)
  margin-bottom: $base-spacing-unit

// bad
.box--narrow
  padding: 16px
  margin-bottom: 32px
```

We use `box-sizing` [set globally to `border-box`][10].

As for the font sizes, we define them using `px`. We also keep them as variables, and to calculate the line height we use [an appropriate Inuit's mixin][11].

To generate icons we use [Fontello][12].

## Plans for the future

At this point, a certain disadvantage is that our website is not responsive. While this is not a problem when using our key service, because it mainly takes place in the shell, but, e.g., reading the blog is getting onerous. We want to improve it, but we are also going to implement responsiveness in stages.

Another thing we are missing is a style guide available to all developers, which would definitely facilitate daily work and testing changes.

The last thing we want to do is updating the Inuit modules we use to [the latest pre-alpha version][13].

[1]: http://markdotto.com/2014/07/23/githubs-css/
[2]: http://codepen.io/chriscoyier/blog/codepens-css
[3]: http://blog.brianlovin.com/buffers-css/
[4]: https://shellycloud.com/blog/2013/11/when-inuitcss-is-a-better-choice-than-bootstrap
[5]: https://github.com/ai/autoprefixer-rails
[6]: https://rails-assets.org
[7]: http://sugarjs.com
[8]: http://csswizardry.com/2013/01/mindbemding-getting-your-head-round-bem-syntax/
[9]: http://bensmithett.com/bem-modifiers-multiple-classes-vs-extend/
[10]: http://css-tricks.com/inheriting-box-sizing-probably-slightly-better-best-practice/
[11]: https://github.com/csswizardry/inuit.css/blob/master/generic/_mixins.scss#L13-L19
[12]: http://fontello.com
[13]: https://github.com/inuitcss
[14]: http://bower.io/search/
