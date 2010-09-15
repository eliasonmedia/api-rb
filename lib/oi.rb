require 'active_support/core_ext/module/attribute_accessors'
require 'logger'

require 'oi/base'
require 'oi/category'
require 'oi/tag'
require 'oi/location'
require 'oi/story'

module OI
  # The API service host
  HOST = 'hyperlocal-api.outside.in'

  # The current version of the API
  VERSION = '1.1'

  mattr_accessor :logger, :instance_writer => false
  # That which logs. Use +OI.logger+ and +OI.logger=+ to access. Defaults to +WARN+.
  @@logger = Logger.new(STDOUT)
  @@logger.level = Logger::WARN

  mattr_accessor :key, :instance_writer => false
  # The developer key used to identify who is making the API request. Use +OI.key+ and +OI.key=+ to access.
  @@key = nil

  mattr_accessor :secret, :instance_writer => false
  # The shared secret used to sign the API request. Use +OI.secret+ and +OI.secret=+ to access.
  @@secret = nil

  # The base class for API exceptions.
  class ApiException < Exception; end

  # Indicates that access was denied to the requested API resource. This may mean that the developer key is invalid
  # or does not provide access to a curated resource.
  class ForbiddenException < ApiException; end

  # Indicates that the requested API resource was not found. Usually this means that a data item was not found for
  # a given UUID or other identifier, but in the case of an SDK bug, it may mean the requested URL was incorrect
  # somehow.
  class NotFoundException < ApiException; end

  # Usually means that something has gone wrong on the service side of the communication.
  class ServiceException < ApiException; end
end
