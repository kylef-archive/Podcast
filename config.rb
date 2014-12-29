set :encoding, 'utf-8'
set :relative_links, true

# Support for browsing from the build folder.
set :strip_index_file,  false

# Automatic image dimensions on image_tag helper
activate :automatic_image_sizes
activate :rouge_syntax

# Reload the browser automatically whenever files change
configure :development do
  activate :livereload
end

# Methods defined in the helpers block are available in templates
$:.unshift(File.expand_path(File.join(__FILE__, '..', 'lib')))
require 'podcast'
helpers do
  def episodes; PodCast::Episode.all; end
  def podcasters; PodCast::Podcaster.all; end
  def podcast; PodCast.podcast; end
  def sentence(ary); ary.to_sentence(two_words_connector: ' & '); end
  def podcaster_links(podcasters)
    sentence(podcasters.map { |p| link_to(p.name, p.url) })
  end
  def twitter_button(twitter)
    %(<a class="twitter-follow-button" href="https://twitter.com/#{twitter}" data-show-count="false" data-lang="en">Follow @#{twitter}</a>)
  end
end

PodCast::Episode.all.each do |episode|
  proxy "/#{episode.number}.html", "/episode.html", locals: { episode: episode, title: episode.title }, :ignore => true
end

PodCast::Podcaster.all.each do |podcaster|
  proxy "/host/#{podcaster.twitter}.html", "/podcaster.html", locals: { podcaster: podcaster, title: podcaster.name }, :ignore => true
end

set :css_dir, 'stylesheets'

set :js_dir, 'scripts'

set :images_dir, 'images'

# Build-specific configuration
configure :build do
  activate :sprockets

  # For example, change the Compass output style for deployment
  activate :minify_css

  # Minify Javascript on build
  activate :minify_javascript

  # Use relative URLs
  activate :relative_assets
end

set :markdown, PodCast::MARKDOWN_OPTIONS
set :markdown_engine, :redcarpet

activate :directory_indexes
