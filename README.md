## Writing posts
### Create new post
To create a new post run a command:
```
middleman article SAMLPE-BLOG-POST-TITLE
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
