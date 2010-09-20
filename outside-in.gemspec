# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{outside-in}
  s.version = "1.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Brian Moseley"]
  s.date = %q{2010-09-20}
  s.email = %q{brian@outside.in}
  s.extra_rdoc_files = [
    "README.md"
  ]
  s.files = [
    ".gitignore",
     "Gemfile",
     "Gemfile.lock",
     "HISTORY",
     "README.md",
     "Rakefile",
     "VERSION",
     "config/oi.sample.yml",
     "lib/outside_in.rb",
     "lib/outside_in/base.rb",
     "lib/outside_in/category.rb",
     "lib/outside_in/location.rb",
     "lib/outside_in/query_params.rb",
     "lib/outside_in/resource/base.rb",
     "lib/outside_in/resource/location_finder.rb",
     "lib/outside_in/resource/story_finder.rb",
     "lib/outside_in/story.rb",
     "lib/outside_in/tag.rb",
     "outside-in.gemspec",
     "tasks/oi.thor"
  ]
  s.homepage = %q{http://github.com/outsidein/api-rb}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Ruby SDK for the Outside.in API}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

