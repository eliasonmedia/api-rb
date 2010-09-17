require 'simple_uuid'

module OI
  # Story model class.
  #
  # Stories have the following attributes:
  #
  # * feed_title
  # * feed_url
  # * story_url
  # * summary
  # * tags - (+Array+ of {OI::Tag})
  # * title
  # * uuid ({SimpleUUID::UUID})
  #
  # Story finders accept query parameter inputs as described by {OI::Story#parameterize_url}. They return data
  # structures as described by {OI::Story#query_result}.
  #
  # @see http://developers.outside.in/docs/stories_query_resource General API documentation for stories
  # @since 1.0
  class Story < Base
    api_attr :feed_title, :feed_url, :story_url, :summary, :title, :uuid
    api_attr :tags => Tag

    SIMPLE_PARAMS = {:limit => :limit, :'max-age' => :max_age}
    NEGATABLE_PARAMS = {:keyword => :keyword, :vertical => :vertical, :format => :format,
      :'author-type' => :'author-type'}

    # Returns the stories attached to +state+.
    #
    # @param [String] state the state name or postal abbreviation
    # @param [Hash<String, Object>] inputs the query parameter inputs
    # @return [Hash<Symbol, Object>] the query result
    # @since 1.0
    def self.for_state(state, inputs = {})
      url = "/states/#{URI.escape(state)}/stories"
      query_result(call_remote(scope_url(url, inputs), QueryParams.new(inputs, SIMPLE_PARAMS, NEGATABLE_PARAMS)))
    end

    # Returns the stories attached to +city+ in +state+.
    #
    # @param [String] state the state name or postal abbreviation
    # @param [String] city the city name
    # @param [Hash<String, Object>] inputs the query parameter inputs
    # @return [Hash<Symbol, Object>] the query result
    # @since 1.0
    def self.for_city(state, city, inputs = {})
      url = "/states/#{URI.escape(state)}/cities/#{URI.escape(city)}/stories"
      query_result(call_remote(scope_url(url, inputs), QueryParams.new(inputs, SIMPLE_PARAMS, NEGATABLE_PARAMS)))
    end

    # Returns the stories attached to +nabe+ in +city+ in +state+.
    #
    # @param [String] state the state name or postal abbreviation
    # @param [String] city the city name
    # @param [String] nabe the neighborhood name
    # @param [Hash<String, Object>] inputs the query parameter inputs
    # @return [Hash<Symbol, Object>] the query result
    # @since 1.0
    def self.for_nabe(state, city, nabe, inputs = {})
      url = "/states/#{URI.escape(state)}/cities/#{URI.escape(city)}/nabes/#{URI.escape(nabe)}/stories"
      query_result(call_remote(scope_url(url, inputs), QueryParams.new(inputs, SIMPLE_PARAMS, NEGATABLE_PARAMS)))
    end

    # Returns the stories attached to +zip+.
    #
    # @param [String] zip the zip code
    # @param [Hash<String, Object>] inputs the query parameter inputs
    # @return [Hash<Symbol, Object>] the query result
    # @since 1.0
    def self.for_zip_code(zip, inputs = {})
      url = "/zipcodes/#{URI.escape(zip)}/stories"
      query_result(call_remote(scope_url(url, inputs), QueryParams.new(inputs, SIMPLE_PARAMS, NEGATABLE_PARAMS)))
    end

    # Returns the stories attached to the locations identified by +uuids+.
    #
    # @param [Array<SimpleUUID::UUID>] uuids the location uuids
    # @param [Hash<String, Object>] inputs the query parameter inputs
    # @return [Hash<Symbol, Object>] the query result
    # @since 1.0
    def self.for_uuids(uuids, inputs = {})
      url = "/locations/#{uuids.map{|u| URI.escape(u.to_guid)}.join(",")}/stories"
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
      inputs['publication-id'].nil?? url : url.gsub(/\/stories$/, "/publications/#{inputs['publication-id']}/stories")
    end

    # Returns the story's title and uuid.
    #
    # @return [String]
    # @since 1.0
    def to_s
      "#{title} (#{uuid.to_guid})"
    end

    # Returns a hash encapsulating the data returned from a successful finder query.
    #
    # The hash contains the following data:
    #
    # * +:total+ - the total number of matching stories (may be greater than the number of returned stories)
    # * +:stories+ - the array of most recent matching {OI::Story} in reverse chronological order as per the
    #   specified or implied limit
    # * +:location+ - the {OI::Location} to which the finder was scoped (present for all non-UUID finders)
    # * +:locations+ - the array of {OI::Location} to which the finder was scoped (present only for the UUID finder)
    #
    # @param [Hash<String, Object>] data the raw query result
    # @return [Hash<Symbol, Object>]
    # @since 1.0
    def self.query_result(data)
      rv = {:total => data['total'], :stories => []}
      if data.include?('locations')
        rv[:locations] = data['locations'].map {|l| Location.new(l)}
      else
        rv[:location] = Location.new(data['location'])
      end
      rv[:stories] = data['stories'].map {|s| new(s)}
      rv
    end
  end
end
