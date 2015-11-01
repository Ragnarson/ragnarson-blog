---
title: Chef best practices
author: staszek
---

Chef is a framework written in Ruby, and partially in Erlang ([Chef Server][chef-server]). It provides an API for numerous system services. With Chef, your infrastructure can be expressed as object-oriented code that is versionable, testable, and repeatable. One of the main ideas of Chef developers was to bury the walls that exist between software development and system administration, allowing them to bring system configuration to a higher level.

In Chef there are [cookbooks][cookbooks] which act as code packages. Cookbooks have scripts called [recipes][recipes] consisting of [resources][resources]. All operations on your repository, and Chef Server, can be made via the [knife][knife] command tool. There are also basic cookbooks that can be downloaded from [Chef Supermarket][chef-market], developed and maintained by [Chef Community][chef-community]. You can also test your code by using your own [kitchen][kitchen].

## Generic cookbooks

The main problem with designing and writing your own cookbooks is keeping them generic. This would probably not be an issue in small organizations, or in private usage, but if you ultimately want to publish your codes, or mix them with existing cookbooks, this is probably the issue in most cases (e.g. multiple declarations of the same service, additional packages/services installed but not required by our stack).

The idea of a generic cookbook is to focus on specific tasks that the service would provide, and nothing more. In its ideal form, it should only install necessary packages and provide an [LWRP (Lightweight Resource/Provider)][lwrp] for available actions (e.g. enabling site in nginx). You should avoid configuring any service that is not strictly related to the particular cookbook (e.g. monitoring, firewall etc.) or at least make it optional and do not include in your installation recipes.

## One cookbook to rule them all

In Shelly Cloud, we use the concept of 'role cookbooks' instead of the built-in roles structure in Chef. In basic terms, this means creating a wrapper cookbook for each role in your infrastructure, which then aggregates a generic cookbook and includes it in your nodes instead of roles. There are numerous advantages of using this approach, such as:

* cookbooks are versionable
* creates another layer for some additional organization-specific logic (e.g. some searches)
* can be distributed just like any other cookbook
* preserves site cookbooks not edited within our repository

A theoretical example of a 'role cookbook' recipe (web_server):

```ruby
# web_server/recipes/default.rb

# configuring used cookbooks
node.default['nginx']['port'] = 80
node.default['monit']['email'] = 'example@example.com'

# including recipies to install components
include_recipe 'nginx::install'
include_recipe 'monit'
include_recipe 'shorewall'

# enabling some sites using nginx cookbook resource
%w(default_site default_site2).each do |site|
  service_vhost site do
    notifies :reload, 'service[nginx]'
  end
end

# adding exceptions for nginx in firewall using shorewall cookbook resource
configure_shorewall4 "nginx" do
  port_number node['nginx']['port']
  protocol "tcp"
end

# setting up monitoring from monit template file
monit_monitrc 'nginx'
```

The example above represents the concept of a role cookbook. On the very first lines, we are overwriting attributes of cookbooks we want to use. Then we include recipes which will trigger a default recipe (in most cases this is an installation and enabling of a service), or include a specific installation recipe (`nginx::install`). After this, we proceed to main service configuration by preparing and enabling 3 sites on our server, simply using ruby for each loop and `service_vhost` as described in `nginx` cookbook. Finally, we ensure that the desired port is open in our firewall (shorewall) and set up monitoring for nginx (monit).

As you can see, if we did any firewall or monitoring configuration inside nginx site cookbook itself, we would not have the ability to choose which software we want to use for this purpose in our stack. The above method also gives us the ability to extend our logic in mixing those services.

There are also some situations where it is just better to use role anyway. You can read more about this at [Chef blog][pro-role-cookbook].

## Berkshelf

As you are interested in Chef, you are probably also familiar with Ruby. Rubists usually use [Bundler][bundler] to manage gems dependencies in their scripts. Over time, Chef gained its own equivalent called [Berkshelf][berkshelf] and eventually this became part of [Chef Development Kit][chef-dk].

The traditional pattern is to place all of your cookbooks in a directory called cookbooks or site-cookbooks, within your Chef Repository. This can be accomplished with a knife tool via the `knife cookbook site install [name]` command. From this point on, it works as a standard git submodule that can be developed independently within your repository.

As a consequence of generic cookbooks design, distributed across multiple repositories, we do not need (and even do not want) to edit the cookbooks directly inside our main workspace repository. Using a berkshelf helps to better organize your repository, and keep it clean from site cookbooks that, if manually edited, can lead to a huge mess and unexpected behavior in future.

Example of Berkshelf file inside your cookbook directory:

```ruby
source "https://supermarket.chef.io"

metadata

cookbook "mysql"
cookbook "nginx", "~> 2.6"
```

Note that the metadata method gathers existing information about dependencies directly from `metadata.rb`.

You can install dependencies and then upload to the server using `berks install`, then use `berks upload` to upload all of them to Chef Server. By default, it downloads all cookbooks to `~/.berkshelf` directory and keeps all downloaded versions.

## Attributes

Node attributes is one of the key features of Chef. It is used as a variable for your cookbooks that specify their state and help to create even more reusable recipes. The default attribute file (`attributes/default/default.rb`) should contain all necessary attributes declarations. As it appears to be common across most cookbooks, you should avoid adding any logic in that file. The best example of undesirable behavior in this case would be composing URLs using conditional blocks, e.g.:

```ruby
default['service']['branch'] = 'stable'

case node['platform_family']
when 'debian'
  default['service']['repo'] = "https://example.com/debian/#{node['service']['branch']}"
when 'rhel'
  default['service']['repo'] = "https://example.com/rhel/#{node['service']['branch']}"
end
```

Unfortunately the examples above have one annoying side effect; Even though Chef has a very clear and complex [attribute precedence][attr-precedence], when it comes to loading the attribute file it will evaluate all blocks before applying all recipes. As a consequence of this, we can't reuse `default['service']['branch']` in role cookbooks and we will have to override the `default['service']['repo']` attribute as well.

## Summary

The above is just a collection of good, effective and verified practices for using Chef on a larger scale. The Chef Community is a very big and diverse society which can offer you problem solving in many different ways that, in some cases, may be more suitable for you. But just as in The Ruby Way, we can still base our efforts on conventions that evolved over time from best practices, and that in turn can help us to become better Chefs.

[chef]:https://www.chef.io/chef/
[pro-role-cookbook]:https://www.chef.io/blog/2013/11/19/chef-roles-arent-evil/
[berkshelf]:https://github.com/berkshelf/berkshelf
[chef-server]:https://docs.chef.io/server_components.html
[cookbooks]:http://docs.chef.io/cookbooks.html
[recipes]:http://docs.chef.io/recipes.html
[resources]:https://docs.chef.io/resource.html
[kitchen]:https://docs.chef.io/kitchen.html
[lwrp]:https://docs.chef.io/lwrp.html
[bundler]:http://bundler.io/
[chef-dk]:https://downloads.chef.io/chef-dk/
[knife]:https://docs.chef.io/knife.html
[chef-market]:https://supermarket.chef.io/cookbooks
[chef-community]:https://www.chef.io/community/
[attr-precedence]:https://docs.chef.io/attributes.html#attribute-precedence
[learn-chef]:https://learn.chef.io/
