module OI
  # A helper class for computing query parameters. These helpers know how to convert input values into query
  # parameters and to add them to query URLs.
  #
  # @since 1.0
  class QueryParams

    # Creates and returns an instance based on various parameter names.
    #
    # For each simple parameter name, a parameter with that name is added when the inputs hash contains a value for
    # that key.
    #
    # Negatable parameters are those which have "include" and "exclude" variants (e.g. category for locations,
    # keyword for stories). An "include" parameter is added when the inputs hash contains a value for the negatable
    # parameter's name, just like for a simple parameter. An exclude parameter prefixed with "no-" is added when the
    # inputs hash contains a value for the parameter's name prefixed with "no-" or the name prefixed with "wo-" (the
    # form used by the Thor tasks, which reserve the "no-" prefix for a different purpose).
    #
    # @param [Hash<Symbol, Symbol>] simple the names of simple input parameters mapped to API parameter names
    # @param [Hash<Symbol, Symbol>] negatable the names of negatable input parameters mapped to API parameter names
    # @return [OI::QueryParams]
    # @since 1.0
    def initialize(simple = {}, negatable = {})
      @simple = simple
      @negatable = negatable
    end

    # Returns the provided URL with parameters attached to the query string.
    #
    # @param [Hash<String, Object>] inputs the query parameter inputs
    # @param [String] url the base query resource URL
    # @return [String] the URL including query parameters
    # @since 1.0
    def parameterize(url, inputs)
      params = []

      @simple.each_pair do |input, api|
        nk = input.to_s
        params << "#{api}=#{inputs[nk]}" unless inputs[nk].nil?
      end

      @negatable.each_pair do |input, api|
        nk = input.to_s
        params.concat(inputs[nk].map {|s| "#{api}=#{URI.escape(s)}"}) unless inputs[nk].nil?
        ["wo-#{input}", "no-#{input}"].each do |nk|
          params.concat(inputs[nk].map {|s| "no-#{api}=#{URI.escape(s)}"}) unless inputs[nk].nil?
        end
      end

      if params.empty?
        url
      else
        sep = url =~ /\?/ ? '&' : '?'
        "#{url}#{sep}#{params.join('&')}"
      end
    end
  end
end
