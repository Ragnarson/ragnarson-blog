---
title: Problems with typical Rails controllers and before actions
author: karol
tags: development
---

One of the most common practices when writing controllers in Rails is using `before_actions` to keep them DRY. Sure, repeating code is a bad practice and leads to maintenance nightmare, but what happens when the readability drastically deteriorates after making the code DRY to the max? Is it still worth it? Let's see how it applies to controllers, what are the consequences and possible solutions.READMORE

## Anatomy of typical Rails controller

Let's take a look how typical Rails controller may look like:

``` ruby
class ArticlesController < ApplicationControler
  before_action :load_article, only: [:show, :edit, :update, :destroy]

  def index
    @articles = Article.all
  end

  def show
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to [:articles]
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @article.update(article_params)
      redirect_to [:articles]
    else
      render :edit
    end
  end

  def destroy
    @article.destroy
    redirect_to [:articles]
  end

  private

  def load_article
    @article ||= Article.find(params[:id])
  end

  def article_params
    params.require(:article).permit(:title, :body, :author_ids)
  end
end
```

Looks pretty innocent, nothing fancy is going on here. The `load_article` method keeps the controller DRY so that we don't need to repeat loading an article in show, edit, update and destroy actions.

That's very similar what scaffold generator would create. Seems like it's also considered as The Rails Way [best practice](http://rails-bestpractices.com/posts/2010/07/24/use-before_filter/). What could possibly go wrong here?

Let's see if we can make it a bit more complex. The articles can have many authors, so we can add loading authors in before actions to still keep the controller DRY.

``` ruby
class ArticlesContrller  < ApplicationController
  before_action :load_authors, only: [:new, :create, :edit, :update]

# other actions

  private

  def load_authors
    @authors ||= Author.all
  end
end
```

Is there any problem with such code? If we take a look at the views we will see some instane variables: `@article` and `@authors`, now let's take a look e.g. at `edit`
action:

``` ruby
def edit
end
```

Any idea where the instance variables come from? Nothing is in the action body. Well, we can of course scan the entire controller looking for proper before action, then go to private method etc., but it's not really ideal. The method is broken into several pieces which are all around controller making it difficult to follow. That example is trivial and already causes some problems. Can you imagine a controller with multiple before actions with only and except options where the the views for creating and editing record are totally different? Good luck with understanding where all the instance variables come from in each action.

## Abusing before actions even more

There are actually even more nasty examples of misusing before actions - modifying params. Imagine that the article can have multiple owners that are selectable in the views, but we also want to add current user to be the owner of the article when creating a new one. To avoid adding some more logic in create method body for whatever reason (maybe to comply with some gems that drive the controller's method flow which happens quite often) or extracting the logic to some proper object (Fear Of New Classes) someone decides to add current user to params in before action:

``` ruby
class ArticlesController < ApplicationController
  # multiple before actions
  before_action :add_current_user_as_owner, only: [:create]
  # even more before actions

  # proper actions

  private

  def add_current_user_as_owner
    # gotcha!
    owner_ids = params[:article][:owner_ids] << current_user.id
    params.deep_merge!(article: { owner_ids: owner_ids })
  end

  def article_params
    params.require(:article).permit(:body, :title, :author_ids, :owner_ids)
  end
end
```

Any idea how could the data in params in create action be different than the one sent with form? Good luck with debugging such issues, especially in legacy apps with huge controllers.

## What are the before actions good for

The only justified usecase for before actions should be something that doesn't have any side effects concerning the state - example would be redirecting to sign in page when the user is not logged in. It doesn't brake the main flow of the action into several pieces, doesn't set any instance variables and works more like a guard clause.

## Making controllers readable again

The proper fix should be to move all the logic from before actions to method body. Just don't fall into another trap where it's not clear where the instance variables come from. Such code is still better than before actions:

``` ruby
class ArticlesController < ApplicationController
  def show
    load_article
  end

  private

  def load_article
    @article ||= Article.find(params[:id])
  end
end
```

but it's not obvious what's available in views, setting some state in private methods is almost always a bad idea. Other semi-fix would be to use `helper_method` to indicate that something is going to be available in views:

``` ruby
class ArticlesController < ApplicationController
  helper_method :article

   def show
    load_article
   end

  private

  def article
    @article
  end

  def load_article
    @article = Article.find(params[:id])
  end
end
```

but it only looks nice if you have one action in controllers, for multiple actions it doesn't really solve the problem. If you want to keep the controllers readable you should make all the instance variables explicit:

``` ruby
class ArticlesController < ApplicationController
  def new
    @article = find_article
    @authors = find_authors
  end
end
```

Or pass the variables explicitly to the views:

``` ruby
class ArticlesContoller < ApplicationController
  def new
    render :new, locals: { article: find_article, authors: find_authors }
  end
end
```

which is actually the safest option: instance variables that are not set return nil, so you won't accidentally run into `NoMethodError` when dealing with non-existent instant variables.

## Wrapping up

Before actions are misused in many situations: either for making the controller DRY or to make the methods look still like typical CRUD, even when it's not the case, which leads to serious deterioration in code readability. Fortunately, you can keep the code readable by setting the state explicitly in method's body.
