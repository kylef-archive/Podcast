desc "Initializes your working copy to have the correct submodules and gems"
task :bootstrap do
  puts "Updating submodules..."
  `git submodule update --init --recursive`

  puts "Installing gems"
  `bundle install`
end

begin
  require 'middleman-gh-pages'

  task :deploy do
    Rake::Task["publish"].invoke
  end

  desc 'Runs the web server locally and watches for changes'
  task :run do
    sh "bundle exec middleman server --port 4567"
  end

  desc 'Start a console with all files loaded'
  task :console do
    require 'pathname'
    exec 'bundle', 'exec', 'irb', '-I', (Pathname(__FILE__).parent + 'lib').to_s, '-r', 'podcast'
  end
rescue Exception => e
  puts 'You must run `rake bootstrap` first!'
end
