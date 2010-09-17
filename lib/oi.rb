require 'active_support/core_ext/module/attribute_accessors'
require 'logger'

require 'oi/query_params'
require 'oi/base'
require 'oi/category'
require 'oi/tag'
require 'oi/location'
require 'oi/story'

module OI
  # The API service host
  # @since 1.0
  HOST = 'hyperlocal-api.outside.in'

  # The current version of the API (not the version of the SDK!)
  # @since 1.0
  VERSION = '1.1'

  mattr_accessor :logger, :instance_writer => false
  # That which logs. Use +OI.logger+ and +OI.logger=+ to access. Defaults to +WARN+.
  # @since 1.0
  @@logger = Logger.new(STDOUT)
  @@logger.level = Logger::WARN

  mattr_accessor :key, :instance_writer => false
  # The developer key used to identify who is making the API request. Use +OI.key+ and +OI.key=+ to access.
  # @since 1.0
  @@key = nil

  mattr_accessor :secret, :instance_writer => false
  # The shared secret used to sign the API request. Use +OI.secret+ and +OI.secret=+ to access.
  # @since 1.0
  @@secret = nil

  # The base class for API exceptions.
  # @since 1.0
  class ApiException < Exception; end

  # Indicates that access was denied to the requested API resource. This may mean that the developer key is invalid
  # or does not provide access to a curated resource.
  # @since 1.0
  class ForbiddenException < ApiException; end

  # Indicates that the requested API resource was not found. Usually this means that a data item was not found for
  # a given UUID or other identifier, but in the case of an SDK bug, it may mean the requested URL was incorrect
  # somehow.
  # @since 1.0
  class NotFoundException < ApiException; end

  # Usually means that something has gone wrong on the service side of the communication.
  # @since 1.0
  class ServiceException < ApiException; end

  # Indicates that a request could not be signed for some reason.
  # @since 1.0
  class SignatureException < ApiException; end
end
