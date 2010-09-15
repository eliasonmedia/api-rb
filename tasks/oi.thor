require 'rubygems'
require 'bundler'
Bundler.setup

# XXX: only do this when the task has not been installed
$: << 'lib'

require 'oi'
require 'text/reform'
require 'yaml'

module OI
  class CLI < Thor
    namespace :oi

  protected
    def run(&block)
      configure
      if ::OI.key && ::OI.secret
        begin
          yield
        rescue ::OI::ForbiddenException => e
          error("Access denied - doublecheck key and secret in #{cfg_file}")
        rescue ::OI::ApiException => e
          error("Invalid API request: #{e.message}")
        end
      end
    end

    def cfg_file
      File.join('config', 'oi.yml')
    end

    def configure
      cfg = YAML.load_file(cfg_file)
      ::OI.key = cfg['key'] or error("You must specify your key in #{cfg_file}")
      ::OI.secret = cfg['secret'] or error("You must specify your secret in #{cfg_file}")
      ::OI.logger.level = Logger::DEBUG
    end

    def warn(msg)
      say_status :WARN, msg, :yellow
    end

    def ok(msg)
      say_status :OK, msg
    end

    def error(msg)
      say_status :ERROR, msg, :red
    end

    def debug(msg)
      say_status :DEBUG, msg, :cyan
    end

    def show_locations(data)
      if data[:locations].empty?
        warn("No matching locations found.")
      else
        names = data[:locations].map do |l|
          l.display_name.length > 32 ? "#{l.display_name[0, 27]} ..." : l.display_name
        end
        uuids = data[:locations].map {|l| l.uuid}
        r = Text::Reform.new
        say(r.format(
          "",
          "Name                              UUID",
          "======================================================================",
          "[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[  [[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[",
          names, uuids,
          "",
          "Best #{data[:locations].size} of #{data[:total]} matching locations"
        ))
      end
    end

    def show_stories(data)
      if data[:stories].empty?
        warn("No stories found.")
      else
        titles = data[:stories].map {|s| s.title.length > 48 ? "#{s.title[0, 43]} ..." : s.title}
        feeds = data[:stories].map {|s| s.feed_title.length > 26 ? "#{s.feed_title[0, 21]} ..." : s.feed_title}
        r = Text::Reform.new
        say(r.format(
          "",
          "Title                                             Feed",
          "============================================================================",
          "[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[  [[[[[[[[[[[[[[[[[[[[[[[[[[",
          titles, feeds,
          "",
          "#{data[:stories].size} most recent of #{data[:total]} stories"
        ))
      end
    end
  end

  class Locations < CLI
    namespace 'oi:locations'

    desc 'named NAME', 'Find locations matching a name'
    method_options :limit => :numeric, :category => :array, :'wo-category' => :array, :'publication-id' => :numeric
    def named(name)
      run do
        show_locations(::OI::Location.named(name, options))
      end
    end
  end

  class Stories < CLI
    namespace 'oi:stories'

    def self.param_method_options
      method_options :limit => :numeric, :'max-age' => :string, :keyword => :array, :'wo-keyword' => :array,
        :vertical => :array, :'wo-vertical' => :array, :format => :array, :'wo-format' => :array,
        :'author-type' => :array, :'wo-author-type' => :array, :'publication-id' => :numeric
    end

    desc 'state STATE', 'Find stories for a state'
    param_method_options
    def state(state)
      run do
        show_stories(::OI::Story.for_state(state, options))
      end
    rescue ::OI::NotFoundException => e
      error("State not found")
    end

    desc 'city STATE CITY', 'Find stories for a city'
    param_method_options
    def city(state, city)
      run do
        show_stories(::OI::Story.for_city(state, city, options))
      end
    rescue ::OI::NotFoundException => e
      error("City not found")
    end

    desc 'nabe STATE CITY NABE', 'Find stories for a neighborhood'
    param_method_options
    def nabe(state, city, nabe)
      run do
        show_stories(::OI::Story.for_nabe(state, city, nabe, options))
      end
    rescue ::OI::NotFoundException => e
      error("Neighborhood not found")
    end

    desc 'zip ZIP', 'Find stories for a zip code'
    param_method_options
    def zip(zip)
      run do
        show_stories(::OI::Story.for_zip_code(zip, options))
      end
    rescue ::OI::NotFoundException => e
      error("Zip code not found")
    end

    desc 'uuid UUID[,UUID[...]]', 'Find stories for one or more location UUIDs'
    param_method_options
    def uuid(uuids)
      run do
        show_stories(::OI::Story.for_uuids(uuids.split(','), options))
      end
    rescue ::OI::NotFoundException => e
      error("UUID not found")
    end

  end
end
