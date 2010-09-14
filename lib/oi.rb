require 'active_support/core_ext/module/attribute_accessors'
require 'logger'

require 'oi/base'
require 'oi/client'
require 'oi/location'

module OI
  mattr_accessor :client
  @@client = nil

  mattr_accessor :logger, :instance_writer => false
  @@logger = Logger.new(STDOUT)
  @@logger.level = Logger::WARN
end
