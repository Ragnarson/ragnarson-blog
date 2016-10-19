require "digest/md5"
require "fastimage"

module CustomHelpers
  def responsive_image_tag(image, image_2x, options = {})
    srcset = "#{image} 1x, #{image_2x} 2x"
    image_tag image, options.merge(srcset: srcset)
  end

  def article_author(article)
    author_slug = article.data.author.downcase
    data.authors[author_slug]
  end

  def avatar(email, size, options = { class: "avatar" })
    email_hash = Digest::MD5.hexdigest(email)
    options[:size] = options[:width] = "#{size}px"
    image_tag("https://www.gravatar.com/avatar/#{email_hash}.jpg?s=#{size * 2}&d=mm", options)
  end

  def author_link(article)
    return "" unless article.data.author
    author = article_author(article)
    if author.twitter
      link_to author.name, "https://twitter.com/#{author.twitter}"
    else
      author.name
    end
  end

  def strip_tags(html)
    Loofah.fragment(html).to_text.strip
  end

  def article_cover(article)
    return unless article.data.cover_photo
    return "<img src='#{article_cover_url(article)}'/>" unless amp?
    cover_path = File.join("source", article.path.gsub(".html", ""), article.data.cover_photo)
    size = FastImage.size(cover_path)
    "<amp-img src='#{article_cover_url(article)}' width='#{size[0]}' height='#{size[1]}' layout='responsive'></amp-img>"
  end

  def article_cover_url(article)
    return unless article.data.cover_photo
    "#{article.url.gsub(".html", "")}/#{article.data.cover_photo}"
  end
end
