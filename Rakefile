begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "oi"
    gemspec.summary = "Ruby SDK for the Mashery API"
    gemspec.email = "brian@outside.in"
    gemspec.homepage = "http://github.com/outsidein/api-rb"
    gemspec.authors = ["Brian Moseley"]
  end
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end

begin
  require 'yard'
  YARD::Rake::YardocTask.new do |t|
    t.options = ['--hide-void-return', '--title', 'Outside.in Ruby SDK']
  end
rescue LoadError
  puts "YARD is not available. Install it with: gem install yard"
end
