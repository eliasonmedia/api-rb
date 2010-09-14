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
#      ::OI.logger.level = Logger::DEBUG
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
    def named(name)
      run do
        show_locations(::OI::Location.named(name))
      end
    end
  end

  class States < CLI
    namespace 'oi:states'

    desc 'stories STATE', 'Find stories for a state'
    def stories(state)
      run do
        show_stories(::OI::Story.for_state(state))
      end
    rescue ::OI::NotFoundException => e
      error("State not found")
    end
  end
end
