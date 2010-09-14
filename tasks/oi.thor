require 'rubygems'
require 'bundler'
Bundler.setup

# XXX: only do this when the task has not been installed
$: << 'lib'

require 'oi'

module OI
  class CLI < Thor
    namespace :oi

  protected
    def run(&block)
      ::OI.logger.level = Logger::DEBUG
      begin
        yield
      end
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
        say "Finding locations named #{name}"
      end
    end
  end
end
