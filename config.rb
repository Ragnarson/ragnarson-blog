require "lib/custom_helpers"
require "lib/custom_renderer"
require "fastimage"
require "json/minify"

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

  # Resources such as images, videos, audio files or ads must be included into
  # an AMP HTML file through custom elements such as <amp-img>. We call them
  # “managed resources” because whether and when they will be loaded and
  # displayed to the user is decided by the AMP runtime.
  #
  # https://www.ampproject.org/docs/get_started/create/include_image.html
  def amp_image_tag(path, options = {})
    if path.start_with?("http") && options[:class] == "avatar"
      avatar_size = options[:size].chomp("px")
      return "<amp-img src='#{path}' width='#{avatar_size}' height='#{avatar_size}' class='avatar'></amp-img>"
    end
    image_path = normalize_image_path(path)
    size = FastImage.size(File.join("source", image_path))
    size = [(size[0] * options[:height].to_i / size[1]).to_i, options[:height].to_i] if options[:height]
    alt_text = options[:alt] ? options[:alt] : path.gsub(/\.[\w]*/, "")
    options.merge!(layout: "responsive") if options[:layout].blank? && options[:srcset].blank?
    "<amp-img #{(options[:layout] ? "layout='#{options[:layout]}'" : "")} src='#{image_path}' alt='#{alt_text}' width='#{size[0].to_s}' height='#{size[1].to_s}'></amp-img>"
  end

  def normalize_image_path(path)
    image_path = File.join("images", path)
    unless File.exists?(File.join("source", image_path))
      image_path = File.join("posts", path)
    end

    image_path.start_with?("/") ? image_path : "/#{image_path}"
  end

  # If Google Search finds the non-AMP version of page, it know there’s an AMP version of it.
  #
  # https://www.ampproject.org/docs/get_started/create/prepare_for_discovery.html
  def amp_or_canonical_link(url, path)
    if amp?
      "<link rel='canonical' href='#{url + path.sub(/amp\//, "")}'>"
    else
      "<link rel='amphtml' href='#{url}/amp#{path}'>"
    end
  end

  def inline_stylesheet(name)
    Middleman::Extensions::MinifyCss::SassCompressor.compress(sprockets[ "#{name}.css" ].to_s)
  end

  def inline_stylesheet_tag(name)
    content_tag(:style, "amp-custom": "") do
      inline_stylesheet(name)
    end
  end

  def inline_ld_json_tag(&block)
    content_tag(:script, "type": "application/ld+json") do
      JSON.minify(block.call)
    end
  end

  def structured_data(type, data)
    {
      "@context": "http://schema.org",
      "@type": type
    }.merge(data).to_json
  end

  def organization_structured_data
    structured_data("Organization",
                    name: "Ragnarson",
                    url: "https://ragnarson.com")
  end

  def website_structured_data
    structured_data("WebSite",
                    name: "Ragnarson Blog",
                    url: "https://blog.ragnarson.com")
  end

  def person_structured_data(author)
    structured_data("Person",
                    name: author.name,
                    image: gravatar_link(author.email, 72))
  end

  def article_structured_data(article)
    data = {
      headline: article.title,
      url: "https://blog.ragnarson.com#{url_for(article)}",
      author: {
        "@type": "Person",
        name: article_author(article).name,
        image: gravatar_link(article_author(article).email, 72)
      },
      publisher: {
        "@type": "Organization",
        name: "Ragnarson",
        url: "https://ragnarson.com",
        logo: "https://blog.ragnarson.com#{image_path("brand.svg")}"
      },
      datePublished: article.date.strftime("%Y-%m-%d"),
      dateModified: article.date.strftime("%Y-%m-%d")
    }

    if article.data.cover_photo
      data.merge!(image: "https://blog.ragnarson.com#{article_cover_url(article)}")
    end

    structured_data("Article", data)
  end

  def image_tag(path, options = {})
    amp? ? amp_image_tag(path, options) : super
  end

  def amp?
    target_name?(:amp)
  end

  def url_for(path_or_resource, options = {})
    url = super

    return url if !target_value(:link_prefix)  || url.scan(/^(http:|https:|)\/\//)[0]

    prefix = target_value(:link_prefix)
    prefix = url[0] == "/" ? "/#{prefix}" : "#{prefix}/"
    "#{prefix}#{url}"
  end

  def full_url(path)
    "https://blog.ragnarson.com#{url_for(path)}"
  end

  def layout_options
    @layout_options ||= {
      links: []
    }
  end

  def append_link(link)
    layout_options[:links].push(link)
  end

  def display_links
    layout_options[:links].map { |meta| tag(:link, meta) }.join.html_safe
  end
end
###

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

# Reload the browser automatically whenever files change
activate :livereload
activate :autoprefixer do |config|
  config.browsers = ["last 2 versions", "Explorer >= 9"]
end

activate :syntax

set :markdown_engine, :redcarpet
set :markdown, CustomRedcarpetHTML::REDCARPET_OPTIONS.merge(renderer: CustomRedcarpetHTML)

set :css_dir, "stylesheets"
set :js_dir, "javascripts"
set :images_dir, "images"

activate :MiddlemanTargets
config[:targets] = {
  default: {
    build_dir: "build",
    link_prefix: nil,
    features: {}
  },
  amp: {
    build_dir: "build/amp",
    link_prefix: "amp",
    features: {}
  }
}

configure :build do
  activate :minify_css
  activate :minify_javascript

  # use asset hash, but ignore post images to be able to display cover photo in post summary
  activate :asset_hash, ignore: /\d{4}\/\d{2}\/\d{2}\//
end

activate :deploy do |deploy|
  deploy.deploy_method = :git
  deploy.strategy = :force_push
end
