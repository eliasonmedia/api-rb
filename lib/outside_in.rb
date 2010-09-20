require 'active_support/core_ext/module/attribute_accessors'
require 'logger'

require 'outside_in/query_params'
require 'outside_in/base'
require 'outside_in/category'
require 'outside_in/tag'
require 'outside_in/location'
require 'outside_in/story'
require 'outside_in/resource/base'
require 'outside_in/resource/location_finder'
require 'outside_in/resource/story_finder'

module OutsideIn
  # The API service host
  # @since 1.0
  HOST = 'hyperlocal-api.outside.in'

  # The current version of the API (not the version of the SDK!)
  # @since 1.0
  VERSION = '1.1'

  mattr_accessor :logger, :instance_writer => false
  # That which logs. Use +OutsideIn.logger+ and +OutsideIn.logger=+ to access. Defaults to +WARN+.
  # @since 1.0
  @@logger = Logger.new(STDOUT)
  @@logger.level = Logger::WARN

  mattr_accessor :key, :instance_writer => false
  # The developer key used to identify who is making the API request. Use +OutsideIn.key+ and +OutsideIn.key=+ to
  # access.
  # @since 1.0
  @@key = nil

  mattr_accessor :secret, :instance_writer => false
  # The shared secret used to sign the API request. Use +OutsideIn.secret+ and +OutsideIn.secret=+ to access.
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

  # Indicates that a query request returned an error response.
  # @since 1.0
  class QueryException < Exception

    # Returns a new instance.
    #
    # @param [Hash<String, Object>] data the error hash returned in the query response body
    # @return [OutsideIn::QueryException]
    # @since 1.0
    def initialize(data)
      if data.include?('error')
        super(data['error'])
      elsif data.include?('errors')
        super(data['errors'].join('; '))
      else
        super('unknown query error')
      end
    end
  end
end
