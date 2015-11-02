---
title: Hide your staging environment from Google
author: grk
shelly: true
---

If you deploy your application to a staging environment, chances are that
it will eventually get picked up by Google and other search engines. This
is undesired for many reasons, from other people discovering your
unfinished work to
[bad SEO from duplicate content](http://moz.com/learn/seo/duplicate-content).

[robots.txt](http://www.robotstxt.org/robotstxt.html) is a file that
can be used to instruct search engine robots not to index certain paths of a
website. Ruby on Rails creates a robots.txt file in the public directory when
generating a new project, but since it is a static file, we can't make it work
for both the production and staging environments.

So, the first step is to remove that file from our repository.

Then, we can make Rails generate different content depending on the enviroment
it is in. While this can be done using a controller, a simpler way is to
create a [Rack](http://rack.github.io/) app.

Create a `lib/robots_txt.rb` file with the following content:

```ruby
class RobotsTxt
  def self.call(env)
    # start building a new response
    response = Rack::Response.new

    # set content type to plain txt file
    response['Content-Type'] = 'text/plain'
    # cache the response for one year, so that further requests won't hit
    # the application
    response['Cache-Control'] = 'public, max-age=31557600' # cache for 1 year

    # if we're not in production env, set the content to disallow all robots
    unless Rails.env.production?
      # disallow access to the whole site (/) for all agents (*)
      response.write "User-agent: *\nDisallow: /"
    end

    response.finish
  end
end
```

Finally, connect that app to the correct route in `config/routes.rb`:

```ruby
YourApp::Application.routes.draw do
  get '/robots.txt' => RobotsTxt
end
```

When you deploy those changes, your app will serve an empty file when running
in the production environment, and disallow all robots from indexing your
site in any other environment.

If you want to lock down your staging environment even further, you can
[use HTTP basic auth](/blog/2012/03/protecting-staging-environment-in-rack).
This way all requests will have to be authenticated with a username and password.
