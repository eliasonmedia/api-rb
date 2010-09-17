require 'simple_uuid'

module OI
  # Location model class.
  #
  # Locations have the following attributes:
  #
  # * category ({OI::Category})
  # * city
  # * display_name
  # * lat ({::Float})
  # * lng ({::Float})
  # * state
  # * state_abbrev
  # * url
  # * url_name
  # * uuid ({SimpleUUID::UUID})
  #
  # Location finders accept query parameter options as described by {OI::Location#parameterize_url}. They return data
  # structures as described by {OI::Location#query_result}.
  #
  # @see http://developers.outside.in/docs/locations_query_resource General API documentation for locations
  # @since 1.0
  class Location < Base
    api_attr :city, :display_name, :lat, :lng, :state, :state_abbrev, :url, :url_name
    api_attr :category => Category
    api_attr :uuid => SimpleUUID::UUID

    # Returns the locations matching +name+. See the API docs for specifics regarding matching rules.
    #
    # @param [String] name the name to match
    # @param [Hash<String, Object>] options the query parameter options
    # @return [Hash<Symbol, Object>] the query result
    # @since 1.0
    def self.named(name, options = {})
      url = "/locations/named/#{URI.escape(name)}"
      query_result(call_remote(parameterize_url(url, options)))
    end

    # Returns the location's display name and uuid.
    #
    # @return [String]
    # @since 1.0
    def to_s
      "#{display_name} (#{uuid.to_guid})"
    end

    # Returns the provided URL with parameters attached to the query string as defined by the provided options.
    #
    # Calls {OI::Base#filter_params} to compute the category parameter.
    #
    # @param [String] url the base query resource URL
    # @param [Hash<String, Object>] options the query parameter options
    # @option options [Integer] publication-id the id of a publication, if location suppression is to be applied
    # @option options [Integer] limit the maximum number of locations to return
    # @option options [Array[String]] category return only locations matching these categorys
    # @option options [Array[String]] no-category return only locations not matching these categories
    # @option options [Array[String]] wo-category return only locations not matching these categories
    # @see OI::Base#filter_params
    # @see http://developers.outside.in/docs/locations_query_resource Acceptable parameter values and defaults
    # @return [String] the URL including query parameters
    # @since 1.0
    def self.parameterize_url(url, options)
      url = "#{url}/publications/#{options['publication-id']}" if options.include?('publication-id')
      qs = []
      qs << "limit=#{options['limit']}" if options.include?('limit')
      qs.concat(filter_params(:category, options))
      qs.empty?? url : "#{url}?#{qs.join('&')}"
    end

    # Returns a hash encapsulating the data returned from a successful finder query.
    #
    # The hash contains the following data:
    #
    # * +:total+ - the total number of matching locations (may be greater than the number of returned stories)
    # * +:locations+ - the array of best matching {OI::Location} as per the specified or implied limit
    #
    # @param [Hash<String, Object>] data the raw query result
    # @return [Hash<Symbol, Object>]
    # @since 1.0
    def self.query_result(data)
      {:total => data['total'], :locations => data['locations'].map {|l| new(l)}}
    end
  end
end
