# Parts taken from https://github.com/hashicorp/middleman-hashicorp/blob/master/lib/middleman-hashicorp/hashicorp.rb

require "middleman-core"
require "middleman-core/renderers/redcarpet"

class CustomRedcarpetHTML < ::Middleman::Renderers::MiddlemanRedcarpetHTML
  REDCARPET_OPTIONS = {
    fenced_code_blocks: true,
    smartypants: true
  }
  
  #
  # Override block_html to support parsing nested markdown blocks.
  #
  # @param [String] raw
  #
  def block_html(raw)
    raw = unindent(raw)

    if md = raw.match(/\<(.+?)\>(.*)\<(\/.+?)\>/m)
      open_tag, content, close_tag = md.captures
      "<#{open_tag}>\n#{recursive_render(unindent(content))}<#{close_tag}>"
    else
      raw
    end
  end

  #
  # This is jank, but Redcarpet does not provide a way to access the
  # renderer from inside Redcarpet::Markdown. Since we know who we are, we
  # can cheat a bit.
  #
  # @param [String] markdown
  # @return [String]
  #
  def recursive_render(markdown)
    Redcarpet::Markdown.new(self.class, REDCARPET_OPTIONS).render(markdown)
  end

  def unindent(string)
    string.gsub(/^#{string.scan(/^[[:blank:]]+/).min_by { |l| l.length }}/, "")
  end
end
