require 'pathname'
require 'uri'
require 'redcarpet'
require 'redcarpet/render_strip'
require 'rouge'

module PodCast
  require 'episode'
  require 'podcaster'

  class Podcast
    ATTRS = %i(
      title
      website
      feed_url
      email
      language
      subtitle
      summary
      explicit
      categories
      podcasters
      keywords
      cover_art
      twitter
    ).freeze

    ATTRS.each do |a|
      attr_reader a
    end

    def self.from_file(file)
      require 'yaml'
      require 'active_support'
      require 'active_support/core_ext/hash'
      yaml = YAML.load(file.read).with_indifferent_access
      episode = new.tap do |e|
        ATTRS.each do |a|
          value = yaml[a]
          next unless value
          if value.is_a? Array
            klass = "PodCast::#{a.to_s.singularize.camelize}".constantize rescue nil
            value.map! { |v| klass.find(v) } if klass
          end
          e.instance_variable_set(:"@#{a}", value)
        end
      end
    end

    def summary_html
      @summary_html ||= PodCast.markdown.render(summary)
    end

    def summary_text
      @summary_text ||= PodCast.markdown_plain.render(summary)
    end

    def authors
      podcasters.sort_by(&:name)
    end
  end

  MARKDOWN_OPTIONS = {
    tables: true,
    autolink: true,
    gh_blockcode: true,
    fenced_code_blocks: true,
    with_toc_data: true,
    no_intra_emphasis: true,
  }.freeze

  class HTML < Redcarpet::Render::HTML
    require 'rouge/plugins/redcarpet'
    include Rouge::Plugins::Redcarpet
    include Redcarpet::Render::SmartyPants
  end

  class Plain < Redcarpet::Render::StripDown
    include Redcarpet::Render::SmartyPants
  end

  def self.podcast
    @podcast ||= Podcast.from_file(Pathname(__FILE__).parent.parent + 'podcast.yml')
  end

  def self.markdown
    @markdown ||= Redcarpet::Markdown.new(HTML, MARKDOWN_OPTIONS)
  end

  def self.markdown_plain
    @markdown_plain ||= Redcarpet::Markdown.new(Plain, MARKDOWN_OPTIONS)
  end

  def self.episodes_path
    Pathname(__FILE__).parent.parent + 'episodes'
  end

  def self.podcasters_path
    Pathname(__FILE__).parent.parent + 'podcasters'
  end
end
