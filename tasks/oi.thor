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
      cfg = read_config
#      ::OI.logger.level = Logger::DEBUG
      ::OI.client = ::OI::Client.new(cfg['key'], cfg['secret'])
      begin
        yield
      end
    end

    def read_config
      YAML.load_file(File.join('config', 'oi.yml'))
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
  end

  class Locations < CLI
    namespace 'oi:locations'

    desc 'named NAME', 'Find locations matching a name'
    def named(name)
      run do
        data = ::OI::Location.named(name)
        if data.empty?
          warn("No matching locations found.")
        else
          names = data[:locations].map {|l| l.display_name}
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
    end
  end
end
