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

    SIMPLE_PARAMS = {:limit => :limit}
    NEGATABLE_PARAMS = {:category => :category}

    # Returns the locations matching +name+. See the API docs for specifics regarding matching rules.
    #
    # @param [String] name the name to match
    # @param [Hash<String, Object>] inputs the data inputs
    # @return [Hash<Symbol, Object>] the query result
    # @since 1.0
    def self.named(name, inputs = {})
      url = "/locations/named/#{URI.escape(name)}"
      query_result(call_remote(scope_url(url, inputs), QueryParams.new(inputs, SIMPLE_PARAMS, NEGATABLE_PARAMS)))
    end

    # Returns a version of +url+ that includes publication scoping when +inputs+ contains a non-nil
    # +publication-id+ entry.
    #
    # @param [String] url the URL to potentially scope
    # @param [Hash<String, Object>] inputs the data inputs
    # @return [String] the URL, scoped if necessary
    # @since 1.0
    def self.scope_url(url, inputs = {})
      inputs['publication-id'].nil?? url : "#{url}/publications/#{inputs['publication-id']}"
    end

    # Returns the location's display name and uuid.
    #
    # @return [String]
    # @since 1.0
    def to_s
      "#{display_name} (#{uuid.to_guid})"
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
