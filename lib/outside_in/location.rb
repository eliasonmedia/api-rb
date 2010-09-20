require 'simple_uuid'

module OutsideIn
  # Location model class.
  #
  # Locations have the following attributes:
  #
  # * category ({OutsideIn::Category})
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
  # Location finders accept query parameter options as described by {OutsideIn::Location#parameterize_url}. They
  # return data structures as described by {OutsideIn::Location#query_result}.
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
    # @param [Hash<String, Object>] inputs the data inputs
    # @return [Hash<Symbol, Object>] the query result
    # @since 1.0
    def self.named(name, inputs)
      query_result(OutsideIn::Resource::LocationFinder.new("/locations/named/#{URI.escape(name)}").GET(inputs))
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
    # * +:locations+ - the array of best matching {OutsideIn::Location} as per the specified or implied limit
    #
    # @param [Hash<String, Object>] data the raw query result
    # @return [Hash<Symbol, Object>]
    # @since 1.0
    def self.query_result(data)
      {:total => data['total'], :locations => data['locations'].map {|l| new(l)}}
    end
  end
end
