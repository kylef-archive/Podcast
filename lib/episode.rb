module PodCast
  class Episode
    ATTRS = %i(
      title
      number
      show_notes
      recorded_on
      published_date
      podcasters
      description
      source
    ).freeze

    ATTRS.each do |a|
      attr_reader a
    end

    def self.from_file(file)
      require 'yaml'
      require 'active_support'
      require 'active_support/core_ext/hash'
      frontmatter, md = file.read.split(/(---.+---)/m).map(&:strip).reject(&:empty?)
      yaml = YAML.load(frontmatter).with_indifferent_access
      episode = new.tap do |e|
        e.instance_variable_set(:@show_notes, md)
        ATTRS.each do |a|
          value = yaml[a]
          next unless value
          if value.is_a? Array
            value.map! { |v| "PodCast::#{a.to_s.singularize.camelize}".constantize.find(v) }
          end
          e.instance_variable_set(:"@#{a}", value)
        end
      end
    end

    def url
      '/' + number.to_s
    end

    def long_title
      "##{number}: #{title}"
    end

    def html_show_notes
      @html_show_notes ||= PodCast.markdown.render(show_notes)
    end

    def html_description
      @html_description ||= PodCast.markdown.render(description)
    end

    def description_text
      @description_text ||= PodCast.markdown_plain.render(description)
    end

    def self.all
      @all ||= PodCast.episodes_path.children
        .select { |c| c.extname() == '.md' }
        .map { |c| from_file(c) }
        .sort_by(&:number)
    end

    def self.find(number)
      all.find { |e| e.number == number }
    end
  end
end
