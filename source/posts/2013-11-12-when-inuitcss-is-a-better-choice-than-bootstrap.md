---
title: When Inuit.css is a better choice than Bootstrap
author: bkzl
shelly: true
---

_"[Inuit.css](http://inuitcss.com/) is a powerful little framework designed for serious developers."_
says the first sentence in a README file.

The biggest advantage of Inuit over other frameworks is modularity
and focus on abstractions. It doesn't enforce how elements should look.
Instead, it gives a set of tools which speed up your work and allow to
test new things faster.

In a certain sense you can compare it to the extended version of [normalize](http://necolas.github.io/normalize.css/)
(which nota bene is included in Inuit), complemented by set of defaults, helpers
and CSS patterns.

The author of the project, [Harry Roberts](https://twitter.com/csswizardry/), is a well-known
front-end developer recognized for his impressive blog - [csswizardry](http://csswizardry.com).
If you don't know him, you should definitely check his site, absolutely one of the best
resource about modern CSS techniques that you can find in the Internet.

This text will refer to the latest version of Inuit - 5.0, released on March 11th 2013.

## Why another framework when I have Bootstrap?

The main difference between Bootstrap and Inuit is that Inuit doesn't provide
design for elements. What does it mean?

Let's compare implementation of a pagination.
In bootstrap `.pagination` class adds borders, colors, link hover effect etc. In Inuit
you only get text alignment and margins, an abstraction of pagination element
without styling details.

From my experience Inuit's approach scales better, because you're adding
your design to convenient defaults. You don't need to override existing attributes
in classes, and you don't have problems with framework upgrades.

Generally, I recommend to stay with Bootstrap only if you won't edit CSS files.

## Installation

There are two ways to integrate Inuit with your project.

As described in Inuit's README, you can use the [inuit.css-web-template](https://github.com/csswizardry/inuit.css-web-template)
to set up your project.

```bash
$ git clone --recursive git@github.com:csswizardry/inuit.css-web-template.git your-project-folder
$ cd your-project-folder
$ ./go
```

Or - the solution which I prefer more - by using bower:

```bash
$ bower install --save inuitcss
```

_You can find more details how to integrate bower with a Rails application [in
one of our previous posts](https://shellycloud.com/blog/2013/09/how-to-manage-front-end-packages-in-rails-with-bower)._

Either way, you have to include Inuit in your main stylesheet. I also recommend creating
a separate file for variables - `_vars.css.scss`.

```scss
@import 'vars';
@import 'inuit.css/inuit';
```

## How to start

You should start working on your project by setting some variables. What I like
in Inuit is that most features are disabled by default. You turn them on
only when you really need them.

At the beginning I suggest the following setup:

```scss
// _vars.css.scss

// Default font-family
$base-font-family: 'Helvetica', sans-serif;

// Default color for borders, horizontal rule etc.
$base-ui-color: #EEE;

// Color and font-family for the brand object
$brand-face: 'Helvetica Neue', sans-serif;
$brand-color: red;

// Push classes to move grid items
$push: true;

// Grid
$use-grids: true;

// Nav abstraction, e.g. throws the list into horizontal mode
$use-nav: true;

// Island and islet objects - http://csswizardry.com/2011/10/the-island-object
$use-island: true;

// Buttons toolkit - http://csswizardry.com/beautons/
$use-beautons: true;
```

## Inuit.css

Inuit is written in SCSS and based on
[the OOCSS methodology](http://oocss.org). OOCSS is growing in popularity
because of its flexibility in creating stylesheets for complex websites.
Also worth noting, it is using [the BEM convenction](http://bem.info)
for class naming. Inuit is compatible with every modern browser and IE8+.

Let's take a closer look at what Inuit offers.

The framework is divided into three main categories: `generic`, `base` and `objects`.
I will explain the concept of each one and describe the most interesting parts,
but you should definitely check the sources yourself because Inuit has a lot of more
interesting things.

### Generic

Very basic, low-level things like: global margins (for vertical rhythm of text),
normalize library, custom reset and the most important in my opinion shared helper
classes and collection of mixins.

Highlights:

* `brand` - handy helpers which allow you to apply your brand font or color to any element
* `debug` - when you enable this, Inuit will detect and mark invalid or wrong nested markup on site
* `helper` - must read, a lot of classes to use arbitrarily, but note that all of them have the `!important` directive
* `mixins` - SCSS helpers, `=font-size`, `=arrow` and `=media-query` are very helpful
* `push` - classes for moving grid elements
* `reset` - Inuit additions to normalize i.e. global box-sizing with border-box, pointer cursor for inputs and labels
* `widths` - sizes in human readable format, mostly used to build a grid

### Base

Design-free styles and modifiers for existing base HTML elements. Things likes code,
headings, paragraphs, images or forms.

Highlights:

* `forms` - instead of a `[type]` selector, add a `.text-input` class to style any kind of form input
* `main` - global settings for html element
* `tables` - columns helpers and table modifiers like `.table--bordered` or `.table--striped`

### Objects

Abstractions of more complex constructs. Patterns like navigation, fluid grid
or pagination. As I said earlier, all objects are disabled by default.

Highlights:

* `beautons` - buttons toolkit
* `grids` - fluid and nestable grid system
* `icon-text` - helper for creating links with icons
* `island` - boxed off content e.g. special blocks in sidebar
* `matrix` - grid of items created from regular list
* `nav` - allows to create horizontal and stacked lists
* `rules` - modifiers for `hr`
* `stats` - useful to display key-value informations

## How to customize Inuit.css

I'm using these simple rules.

First, I check if I can change the styling by editing an Inuit variable. If
that's the case I simply set the variable in `_vars.css.scss`.

If not, I add a CSS override. I like to put my overrides in places analogical to Inuit.
So, if I want to add styles for form inputs, I would create in the main stylesheets directory
file `base/_forms.css.sass` with:

```scss
.text-input,
textarea {
  border-radius: 3px;
  background: white;
  border: 1px solid $base-ui-color;
}
```

Specific CCS rules, like `.registration-form` should be put in a separate layer: `ui`.

So the final structure of directories should look like:

```
stylesheets/
  inuit.css/
    base/
    generic/
    objects/
  base/
    _forms.css.scss
  ui
    _registration-form.css.scss
  application.css.scss
  _vars.css.scss
```

## Summary

Inuit teaches a different way to code CSS, which works great for building
complex websites. Variety of components available in Inuit speed up styling
and encourages reuse of elements common to all web applications.

Sadly, it has two major problems.

First, it lacks good documentation. Although it has great
descriptions in sources even with examples of markup, for many people it isn't enough.

Second, it is not actively maintained. There have been no new commits in the master
branch for five months, and the project has 65 issues and 21 pull requests. Some days ago
the author mentioned on Twitter that he's thinking about founding on Kickstarter to
bring the project back on track. I cross my fingers for this.

### Further research

If you like this topic and want to know more about Inuit, check following links:

* [Project on GitHub](https://github.com/csswizardry/inuit.css)
* [Harry Roberts' blog](http://csswizardry.com)
* [BEM Methodology](http://bem.info/method/)
* [Object-Oriented CSS](http://oocss.org)
