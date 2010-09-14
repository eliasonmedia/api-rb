require 'active_support/core_ext/module/attribute_accessors'
require 'logger'

module OI
  mattr_accessor :logger, :instance_writer => false
  @@logger = Logger.new(STDOUT)
  @@logger.level = Logger::WARN
end
