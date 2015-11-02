---
title: The difference between back-references and global variables in Ruby regular expressions
author: smefju
shelly: true
---

Regular expressions are widely used in the daily work of developers. For example, I can use the [gsub method][1] when I want to replace all the vowels in a given string with the underscore symbol:

```ruby
"here will be dragons".gsub(/([aeiouy])/, "_")
=> "h_r_ w_ll b_ dr_g_ns"
```

The question is how to wrap each matched vowel with the underscore. The first solution is to use the **back-reference** in a *replacement* argument:

```ruby
"here will be dragons".gsub(/([aeiouy])/, '_\1_')
=> "h_e_r_e_ w_i_ll b_e_ dr_a_g_o_ns"
```

Keep in mind that a back-reference needs an extra backslash if it occurs in double quotation marks. The second solution is to use a **block** instead of the *replacement* argument:

```ruby
"here will be dragons".gsub(/([aeiouy])/) { "_#{$1}_" }
=> "h_e_r_e_ w_i_ll b_e_ dr_a_g_o_ns"
```

In this case, I use the `$1` global variable instead of the `\1` back-reference. The reason is that global variables, used within the `gsub` call, will not refer to the current match - they will refer to the previous one, or will be set to `nil` if there was no regular expression match before:

```ruby
"dragons".gsub(/(\w+)s/, $1)
# TypeError: no implicit conversion of nil into String
# from (pry):1:in `gsub'

$1
=> nil

"birds".gsub(/(\w+)s/, '\1')
=> "bird"

"dragons".gsub(/(\w+)s/, $1)
=> "bird"

$1
=> "dragon"
```

This example shows that even a small mistake in the code can cause strange behavior, which can be hard to discover and fix.

To summarize, use back-references for processing strings within the `gsub` method call. Choose global variables when using a block instead of a *replacement* argument, or if the regexp call is before manipulating with the result.

[1]: http://ruby-doc.org/core-2.2.0/String.html#method-i-gsub
