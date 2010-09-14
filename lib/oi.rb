require 'active_support/core_ext/module/attribute_accessors'
require 'logger'

require 'oi/base'
require 'oi/location'
require 'oi/story'

module OI
  HOST = 'hyperlocal-api.outside.in'
  VERSION = '1.1'

  mattr_accessor :logger, :instance_writer => false
  @@logger = Logger.new(STDOUT)
  @@logger.level = Logger::WARN

  mattr_accessor :key, :instance_writer => false
  @@key = nil

  mattr_accessor :secret, :instance_writer => false
  @@secret = nil

  class ForbiddenException < Exception; end
  class NotFoundException < Exception; end
end
