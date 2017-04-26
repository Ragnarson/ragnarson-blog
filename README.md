## Writing posts
### Create new post
To create a new post run a command:
```
middleman article SAMPLE-BLOG-POST-TITLE
```
as a result following file will be created:
```
source/posts/2016-05-09-sample-blog-post-title.html.markdown
```
Add your content to the file. If you want to add any images/files to your post, create a folder with post name and placed them their:
```
mkdir source/posts/2016-05-09-sample-blog-post-title
```
If you create a blog post file on your own remember it has to contain `.html` pre-extanstion to be displayed.
### Post summary
The beginning of the post content is displayed on the main page as a post summary. By default post summary contains first 250 characters of article. You can change it by placing `READMORE` mark in the place where summary should end for your article
### Cover photo
You can add cover photo to your blog post. Add a `cover_photo` option to post YAML frontmatter, e.g.
```
---
title: When involvement rhymes with enjoyment
author: piotr
cover_photo: cover.png
---
```
The cover photo should be placed in post directory.

Build static files:
```
$ bundle exec middleman build_all
```

Run server:
```
$ bundle exec rake server
```

Open normal website:
```
http://localhost:4567/index.html
```

Open AMP website:
```
http://localhost:4567/amp/index.html
```

Validate Accelerated Mobile Pages (AMP) website:
```
http://localhost:4567/amp/index.html#development=1
```

Read more about Accelerated Mobile Pages (AMP) validation:
```
https://www.ampproject.org/docs/guides/validate
```

### Deployment

To deploy static website, use the following rake task:

```
$ bundle exec rake deploy
```

Note that blog uses Accelerated Mobile Pages (AMP). Default middleman deploy task will not build all necessary dependencies for AMP. deploy rake task runs middleman build_all first and then deploy task.
