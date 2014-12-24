module PodCast
  class Podcaster
    ATTRS = %i(
      name
      twitter
      github
      bio
    ).freeze

    ATTRS.each do |a|
      attr_reader a
    end

    def self.from_file(file)
      require 'yaml'
      require 'active_support/core_ext/hash'
      yaml = YAML.load(file.read).with_indifferent_access
      podcaster = new.tap do |p|
        ATTRS.each do |a|
          value = yaml[a]
          p.instance_variable_set(:"@#{a}", value)
        end
      end
    end

    def url
      '/host/' + twitter
    end

    def self.all
      @all ||= PodCast.podcasters_path.children.map { |c| from_file(c) }.sort_by(&:name)
    end

    def self.find(twitter)
      all.find { |p| p.twitter == twitter }
    end

    def episodes
      Episode.all.select { |e| e.podcasters.include? self }
    end
  end
end
