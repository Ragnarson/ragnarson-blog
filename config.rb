require "lib/custom_helpers"
require "lib/custom_renderer"
helpers CustomHelpers
###
# Blog settings
###

# Time.zone = "UTC"

activate :blog do |blog|
  # This will add a prefix to all links, template references and source paths
  # blog.prefix = "blog"

  # blog.permalink = "{year}/{month}/{day}/{title}.html"
  # Matcher for blog source files
  blog.sources = "posts/{year}-{month}-{day}-{title}.html"
  # blog.taglink = "tags/{tag}.html"
  blog.layout = "blog_layout"
  # blog.summary_separator = /(READMORE)/
  # blog.summary_length = 250
  # blog.year_link = "{year}.html"
  # blog.month_link = "{year}/{month}.html"
  # blog.day_link = "{year}/{month}/{day}.html"
  # blog.default_extension = ".markdown"

  blog.tag_template = "tag.html"
  blog.calendar_template = "calendar.html"

  # Enable pagination
  blog.paginate = true
  blog.per_page = 10
  blog.page_link = "page/{num}"
end

activate :sprockets

page "/feed.xml", layout: false

###
# Compass
###

# Change Compass configuration
# compass_config do |config|
#   config.output_style = :compact
# end

###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
# page "/path/to/file.html", layout: false
#
# With alternative layout
# page "/path/to/file.html", layout: :otherlayout
#
# A path which all have the same layout
# with_layout :admin do
#   page "/admin/*"
# end

# Proxy pages (http://middlemanapp.com/basics/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", locals: {
#  which_fake_page: "Rendering a fake page with a local variable" }

data.authors.collect {|author| author }.each do |author|
  proxy "/authors/#{Blog::UriTemplates.safe_parameterize(author.last["name"])}.html",
        "/author.html",
        locals: { author_slug: author.first },
        ignore: true
end

###
# Helpers
helpers do
  def find_author(author_slug)
    result = data.authors.select { |author| author == author_slug.downcase }
    result.any? ? result.first[1] : nil
  end

  def articles_by_author(author_slug)
    sitemap.
      resources.
      select { |resource| resource.data.author == author_slug }.
      sort_by { |resource| resource.data.date }.
      reverse
  end

  def author_link(author)
    link_to author.name, "/authors/#{Blog::UriTemplates.safe_parameterize(author.name)}.html"
  end
end
###

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

# Reload the browser automatically whenever files change
activate :livereload
activate :autoprefixer do |config|
  config.browsers = ['last 2 versions', 'Explorer >= 9']
end

activate :syntax

set :markdown_engine, :redcarpet
set :markdown, CustomRedcarpetHTML::REDCARPET_OPTIONS.merge(renderer: CustomRedcarpetHTML)

set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'

configure :build do
  activate :minify_css
  activate :minify_javascript

  # use asset hash, but ignore post images to be able to display cover photo in post summary
  activate :asset_hash, ignore: /\d{4}\/\d{2}\/\d{2}\//
  # activate :relative_assets
end

activate :deploy do |deploy|
  deploy.build_before = true
  deploy.deploy_method = :git
  deploy.strategy = :force_push
end
