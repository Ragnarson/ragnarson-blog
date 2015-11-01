---
title: How to integrate AngularJS with Rails 4
author: michalkw
---

Building most single-page applications (SPAs for short) is a two-step process:
first you create a JSON API in a backend technology of choice and then you use
that API in the JavaScript application. Here we'll be using [Ruby on
Rails](http://rubyonrails.org/) on the backend and
[AngularJS](http://angularjs.org/) on the frontend.

The main pain point of any kind of integration is making sure that everything
fits together well. This post will *not* take you through building the whole
application. Instead, it will focus on making sure all the integration points
are handled properly. I will also share with you some practical advice on the
topic.

Code examples used in this post come from a [Todo list management
application](https://github.com/mkwiatkowski/todo-rails4-angularjs). This text
summarizes all the lessons learned during writing of that app.


## Building a JSON API in Rails

Building an API in Rails is easy, so we'll roll our own from scratch. Note that
if you decide to use a specialized library like
[angularjs-rails-resource](https://github.com/FineLinePrototyping/angularjs-rails-resource)
some details will differ, but the general idea will remain the same.

### Routing

Let's start by defining routes for our API.

```ruby
namespace :api, defaults: {format: :json} do
  resources :task_lists, only: [:index] do
    resources :tasks, only: [:index, :create, :update, :destroy]
  end
end
```

This is all pretty standard. We can get all lists through the task_lists#index
action, get a task listing for a specific list via tasks#index action and
operate on specific tasks via create, update and destroy actions. Using `format:
:json` is a handy default.

If we run `rake routes` now, we will get an output similar to this:

```
GET    /api/task_lists/:task_list_id/tasks(.:format)     api/tasks#index {:format=>:json}
POST   /api/task_lists/:task_list_id/tasks(.:format)     api/tasks#create {:format=>:json}
PATCH  /api/task_lists/:task_list_id/tasks/:id(.:format) api/tasks#update {:format=>:json}
PUT    /api/task_lists/:task_list_id/tasks/:id(.:format) api/tasks#update {:format=>:json}
DELETE /api/task_lists/:task_list_id/tasks/:id(.:format) api/tasks#destroy {:format=>:json}
GET    /api/task_lists(.:format)                         api/task_lists#index {:format=>:json}
```

There are two HTTP verbs corresponding to the update action: PATCH and
PUT. Supporting PATCH is a new feature added in Rails 4.0. You can read more
about it on [the offical
blog](http://weblog.rubyonrails.org/2012/2/25/edge-rails-patch-is-the-new-primary-http-method-for-updates/).

### Request parameters

Rails 4 also changed the way the mass-assignment protection is done. Instead of
whitelisting/blacklisting parameters in the model, you now have to do it in the
controller, using `require` and `permit` methods. I like to create a helper
method than can be used both in create and update actions:

```ruby
def safe_params
  params.require(:task).permit(:description, :priority, :completed)
end
```

With this definition, action implementation looks as simple as this:

```ruby
def create
  task = task_list.tasks.create!(safe_params)
  render json: task, status: 201
end

def update
  task.update_attributes(safe_params)
  render nothing: true, status: 204
end
```

### Generating JSON

The previous example already hinted at this: returning JSON output should be as
simple as writing `render json: object`. I like to use
[active_model_serializers](https://github.com/rails-api/active_model_serializers/)
gem which greatly simplifies the process. Whenever you render an object or a
collection of objects to json, a proper serializer will be used. In case of our
Todo list application, the following will render an array of tasks:

```ruby
render json: TaskList.find(params[:id]).tasks
```

To get the exact format we want (that will be easy to consume by AngularJS),
after installing the gem, we also need to configure it. Put the following into
`config/initializers/active_model_serializers.rb`:

```ruby
ActiveSupport.on_load(:active_model_serializers) do
  # Disable for all serializers (except ArraySerializer)
  ActiveModel::Serializer.root = false

  # Disable for ArraySerializer
  ActiveModel::ArraySerializer.root = false
end
```

With this configuration in place and a serializer defined like that:

```ruby
# app/serializers/task_serializer.rb
class TaskSerializer < ActiveModel::Serializer
  attributes :id, :description, :priority, :due_date, :completed
end
```

we'll get the following output:

```ruby
[
 {'id' => 123,
  'description' => 'Send newsletter',
  'priority' => 2,
  'due_date' => '2013-09-10',
  'completed' => true},
 {'id' => 124,
  'description' => 'Prepare presentation',
  'priority' => 1,
  'due_date' => '2013-09-17',
  'completed' => false}
]
```


### Testing

All respectable APIs have to be well tested. Fortunately, Rails makes writing
automated tests really easy. In case of a JSON API, controller tests are the way
to go. That's how a sample test may look like, using RSpec syntax:

```ruby
describe Api::TasksController do
  it "should be able to create a new record" do
    post :create, task_list_id: task_list.id,
      task: {description: "New task"}, format: :json
    response.should be_success
    JSON.parse(response.body).should == {'id' => 123, ...}
  end
end
```

An important detail to note here is the use of `format: :json`. This makes sure
that the parameters are passed and interpreted as JSON.

When writing more tests like this, you may find it useful to define a helper
method for parsing the response. Put the following into your `spec_helper.rb`:

```ruby
module JsonApiHelpers
  def json_response
    @json_response ||= JSON.parse(response.body)
  end
end

RSpec.configure do |config|
  config.include JsonApiHelpers, type: :controller
end
```

With this code in place, instead of:

```ruby
JSON.parse(response.body).should == {...}
```

you can now write:

```ruby
json_response.should == {...}
```

which is a little cleaner, you must admit. It also has an added bonus that the
response will be only parsed once, even if you make multiple assertions on the
output.

## Building AngularJS application

Since the API is ready it's finally time to move on to building the AngularJS
application. There is a breadth of tutorials to [watch](http://egghead.io/) and
[read](http://docs.angularjs.org/tutorial), so I'm not going to repeat that
here, instead focusing solely on the integration with Rails.

### Including AngularJS files

The fastest way to get started is putting the JavaScript include tags for
AngularJS directly into layout. At the time of writing this post, 1.0.8 is the
latest stable version, so if you want to use that, put the following two lines
into `app/views/layouts/application.html.slim`:

```
= javascript_include_tag "//ajax.googleapis.com/ajax/libs/angularjs/1.0.8/angular.min.js"
= javascript_include_tag "//ajax.googleapis.com/ajax/libs/angularjs/1.0.8/angular-resource.min.js"
```

Of course you can also download the files and put them somewhere in
`app/assets/javascripts/`. Unfortunately the asset pipeline may break some of
your AngularJS code due to renaming. To prevent that, put the following line
into your `config/environments/production.rb`:

```ruby
config.assets.js_compressor = Uglifier.new(mangle: false)
```

This will disable name mangling during JavaScript minification. You can read
more about this topic in [the official
tutorial](http://docs.angularjs.org/tutorial/step_05) (scroll down to "A Note on
Minification").

### Structuring the AngularJS code

Each AngularJS application consists of the main application module and some
controllers, directives and services. As long as you keep everything under
`app/assets/javascripts/` the asset pipeline will put them all together without
a problem. Ultimately it's up to you where to put each of them, but here's how
I've done it.

First, my `application.js` lists all the external requirements (like jQuery or
AngularJS itself), then the file containing the main application module,
to finally use the `require_tree` directive:

```
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require lib/angular.min
//= require lib/angular-resource.min
//= require todoApp
//= require_tree .
```

With that in mind, the main application module is defined in `todoApp.js.coffee`
and looks like this:

```coffeescript
todoApp = angular.module('todoApp', ['ngResource'])
```

I keep the rest of the files in suitable subdirectories: `controllers`,
`directives` and `services` for standard elements of an AngularJS app, and `lib`
for any other dependencies.

### Defining the service

The Rails API can be accessed from the AngularJS app through the
[ngResource](http://docs.angularjs.org/api/ngResource) module. Instead of using
the resource directly in the controller, it's a good practice to define a
service around it. This way you can abstract away some pesky details of
accessing data, much like you would do with Rails models.

Below is a basic service for accessing tasks, written in CoffeeScript.

```coffeescript
angular.module('todoApp').factory 'Task', ($resource) ->
  class Task
    constructor: (taskListId) ->
      @service = $resource('/api/task_lists/:task_list_id/tasks/:id',
        {task_list_id: taskListId, id: '@id'})

    create: (attrs) ->
      new @service(task: attrs).$save (task) ->
        attrs.id = task.id
      attrs

    all: ->
      @service.query()
```

For example, to get a list of all tasks from a given list, you'd do the
following:

```coffeescript
$scope.tasks = Task(taskListId).all()
```

It cannot get any easier than this.

### Making it work with CSRF protection

Rails come with cross-site request forgery protection in the form of a token
embedded in the head section of each page. To make forms work in AngularJS you
need to use that token in all API requests. Put the following three lines into
the main application file (`todoApp.js.coffee` in our case):

```coffeescript
todoApp.config ($httpProvider) ->
  authToken = $("meta[name=\"csrf-token\"]").attr("content")
  $httpProvider.defaults.headers.common["X-CSRF-TOKEN"] = authToken
```

### Making it work with turbolinks

Turbolinks which [became a default in Rails
4](https://twitter.com/dhh/status/251024691337244672) may cause some problems to
AngularJS applications, especially if you need to support different SPAs on
multiple pages. To overcome this problem, put the following into the main
application file:

```ruby
$(document).on 'page:load', ->
  $('[ng-app]').each ->
    module = $(this).attr('ng-app')
    angular.bootstrap(this, [module])
```

This will make sure the AngularJS application is properly initialized each time
a turbolink does its fetch&replace magic.

### Making updates using the PATCH method

The new PATCH method mentioned in the beginning of this post is not supported by
`ngResource` by default, but it's easy enough to make it work. First, put the
following code into the main application file:

```coffeescript
defaults = $http.defaults.headers
defaults.patch = defaults.patch || {}
defaults.patch['Content-Type'] = 'application/json'
```

It will ensure any PATCH requests are made with `application/json` content type.

After that, modify the resource definition from before, so that it specifies
PATCH as a prefered verb for the update action.

```coffeescript
$resource('/api/task_lists/:task_list_id/tasks/:id',
  {task_list_id: taskListId, id: '@id'},
  {update: {method: 'PATCH'}})
```

Now, whenever you issue an update on the resource, it will properly submit a
PATCH request with JSON content.

### Testing

Just as Rails, AngularJS has a great testing story. Thanks to its focus on
Dependency Injection, unit testing components of an AngularJS application is a
breeze.

[The official tutorial](http://docs.angularjs.org/tutorial/) walks you through
setting up testing infrastructure, using
[Karma](http://karma-runner.github.io/0.10/index.html), so I'm not going to
repeat that here. I found it easy to use with
[Jasmine](http://pivotal.github.io/jasmine/) which I already knew and with
[angular-mocks](http://code.angularjs.org/1.0.8/angular-mocks.js) which helps
with mocking some features of a web browser.

### Debugging

When testing fails it's often useful to be able to boot up the browser and poke
around manually. As I was learning AngularJS and figuring out integration
problems, [Misko Hevery's answer on
Stackoverflow](http://stackoverflow.com/questions/10490570/call-angular-js-from-legacy-code)
was a big help to me.

Turns out, inspecting AngularJS app internals from the browser is not that
complicated. All you need to do is to grab an element with jQuery. For example,
that's how you can access scope in the context of the `taskDescription` element:

```
$("#taskDescription").scope()
```

From there you can traverse the complete state of your controller.

Another tool that may come in handy is [AngularJS
Batarang](https://chrome.google.com/webstore/detail/angularjs-batarang/ighdmehidhipcmcojjgiloacoafjmpfk),
a Chrome extension that allows you to inspect and profile your SPA's internals.

## Now go and build!

That should get you through the initial steps of building your dream single-page
application.

Leave your thoughts in the comments and if you need a hosting for your Rails backend
[you don't have to look far](http://shellycloud.com/). :)
