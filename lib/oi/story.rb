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
  # Story finders accept query parameter options as described by {OI::Story#parameterize_url}. They return data
  # structures as described by {OI::Story#query_result}.
  #
  # @see http://developers.outside.in/docs/stories_query_resource General API documentation for stories
  # @since 1.0
  class Story < Base
    api_attr :feed_title, :feed_url, :story_url, :summary, :title, :uuid
    api_attr :tags => Tag

    # Returns the stories attached to +state+.
    #
    # @param [String] state the state name or postal abbreviation
    # @param [Hash<String, Object>] options the query parameter options
    # @return [Hash<Symbol, Object>] the query result
    # @since 1.0
    def self.for_state(state, options = {})
      url = "/states/#{URI.escape(state)}/stories"
      query_result(call_remote(parameterize_url(url, options)))
    end

    # Returns the stories attached to +city+ in +state+.
    #
    # @param [String] state the state name or postal abbreviation
    # @param [String] city the city name
    # @param [Hash<String, Object>] options the query parameter options
    # @return [Hash<Symbol, Object>] the query result
    # @since 1.0
    def self.for_city(state, city, options = {})
      url = "/states/#{URI.escape(state)}/cities/#{URI.escape(city)}/stories"
      query_result(call_remote(parameterize_url(url, options)))
    end

    # Returns the stories attached to +nabe+ in +city+ in +state+.
    #
    # @param [String] state the state name or postal abbreviation
    # @param [String] city the city name
    # @param [String] nabe the neighborhood name
    # @param [Hash<String, Object>] options the query parameter options
    # @return [Hash<Symbol, Object>] the query result
    # @since 1.0
    def self.for_nabe(state, city, nabe, options = {})
      url = "/states/#{URI.escape(state)}/cities/#{URI.escape(city)}/nabes/#{URI.escape(nabe)}/stories"
      query_result(call_remote(parameterize_url(url, options)))
    end

    # Returns the stories attached to +zip+.
    #
    # @param [String] zip the zip code
    # @param [Hash<String, Object>] options the query parameter options
    # @return [Hash<Symbol, Object>] the query result
    # @since 1.0
    def self.for_zip_code(zip, options = {})
      url = "/zipcodes/#{URI.escape(zip)}/stories"
      query_result(call_remote(parameterize_url(url, options)))
    end

    # Returns the stories attached to the locations identified by +uuids+.
    #
    # @param [Array<SimpleUUID::UUID>] uuids the location uuids
    # @param [Hash<String, Object>] options the query parameter options
    # @return [Hash<Symbol, Object>] the query result
    # @since 1.0
    def self.for_uuids(uuids, options = {})
      url = "/locations/#{uuids.map{|u| URI.escape(u.to_guid)}.join(",")}/stories"
      query_result(call_remote(parameterize_url(url, options)))
    end

    # Returns the story's title and uuid.
    #
    # @return [String]
    # @since 1.0
    def to_s
      "#{title} (#{uuid.to_guid})"
    end

    # Returns the provided URL with parameters attached to the query string as defined by the provided options.
    #
    # Calls {OI::Base#filter_params} to compute keyword and taxonomy parameters.
    #
    # @param [String] url the base query resource URL
    # @param [Hash<String, Object>] options the query parameter options
    # @option options [Integer] publication-id the id of a publication, if curation is to be applied
    # @option options [Integer] limit the maximum number of stories to return
    # @option options [String] max-age the maximum age of stories to return
    # @option options [Array[String]] keyword return only stories matching these keywords
    # @option options [Array[String]] no-keyword return only stories not matching these keywords
    # @option options [Array[String]] wo-keyword return only stories not matching these keywords
    # @option options [Array[String]] vertical return only stories matching these verticals
    # @option options [Array[String]] no-vertical return only stories not matching these verticals
    # @option options [Array[String]] wo-vertical return only stories not matching these verticals
    # @option options [Array[String]] format return only stories matching these formats
    # @option options [Array[String]] no-format return only stories not matching these formats
    # @option options [Array[String]] wo-format return only stories not matching these formats
    # @option options [Array[String]] author-type return only stories matching these author-types
    # @option options [Array[String]] no-author-type return only stories not matching these author-types
    # @option options [Array[String]] wo-author-type return only stories not matching these author-types
    # @see OI::Base#filter_params
    # @see http://developers.outside.in/docs/stories_query_resource Acceptable parameter values and defaults
    # @return [String] the URL including query parameters
    # @since 1.0
    def self.parameterize_url(url, options)
      url = url.gsub(/\/stories$/, "/publications/#{options['publication-id']}/stories") if
        options.include?('publication-id')
      qs = []
      qs << "limit=#{options['limit']}" if options.include?('limit')
      qs << "max_age=#{URI.escape(options['max-age'])}" if options.include?('max-age')
      qs.concat(filter_params(:keyword, options))
      qs.concat(filter_params(:vertical, options))
      qs.concat(filter_params(:format, options))
      qs.concat(filter_params(:'author-type', options))
      qs.empty?? url : "#{url}?#{qs.join('&')}"
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
