require 'pathname'
require 'uri'
require 'redcarpet'
require 'rouge'

module PodCast
  require 'episode'
  require 'podcaster'

  MARKDOWN_OPTIONS = {
    :tables => true,
    :autolink => true,
    :gh_blockcode => true,
    :fenced_code_blocks => true,
    :with_toc_data => true
  }.freeze

  class HTML < Redcarpet::Render::HTML
    require 'rouge/plugins/redcarpet'
    include Rouge::Plugins::Redcarpet # yep, that's it.
  end

  def self.markdown
    @markdown ||= Redcarpet::Markdown.new(HTML, MARKDOWN_OPTIONS)
  end

  def self.podcast_url
    URI('http://kylef.github.io/PodCast/')
  end

  def self.episodes_path
    Pathname(__FILE__).parent.parent + 'episodes'
  end

  def self.podcasters_path
    Pathname(__FILE__).parent.parent + 'podcasters'
  end
end
