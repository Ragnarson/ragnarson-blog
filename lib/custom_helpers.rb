require "digest/md5"

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
    image_tag("https://www.gravatar.com/avatar/#{email_hash}.jpg?s=#{size * 2}&d=mm", options)
  end

  def author_link(article)
    return "" unless article.data.author
    author = article_author(article)
    email_hash = Digest::MD5.hexdigest(author.email)
    link_to "https://twitter.com/#{author.twitter}" do
      avatar(author.email, 23) + " " + author.name
    end
  end
end
