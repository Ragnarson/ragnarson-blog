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
    options[:size] = options[:width] = "#{size}px"
    image_tag(gravatar_link(email, size), options)
  end

  def gravatar_link(email, size)
    email_hash = Digest::MD5.hexdigest(email)
    "https://www.gravatar.com/avatar/#{email_hash}.jpg?s=#{size * 2}&d=mm"
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
    return "<img src='#{article_cover_url(article)}'/>"
  end

  def article_cover_url(article)
    return unless article.data.cover_photo
    image_path "#{article.path.gsub(".html", "")}/#{article.data.cover_photo}"
  end
end
