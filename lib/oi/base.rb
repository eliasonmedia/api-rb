require 'httparty'
require 'json'
require 'md5'

module OI
  # The base class for API models.
  #
  # Models interact with the remote service through the low level {#call_remote} method. Each model class
  # defines its own high-level finder methods that encapsulate the remote service call. For example:
  #
  #  module OI
  #    class Thing < Base
  #      def self.by_name(name)
  #        new(call_remote("/things/named/#{URI.escape(name)}"))
  #      end
  #    end
  #  end
  #
  # Model attributes are declared using {#api_attr}. Only attributes declared this way are recognized by the
  # initializer when setting the model's initial state.
  #
  # @abstract Subclass and declare attributes with {#api_attr} to implement a custom model class.
  # @since 1.0
  class Base
    class << self
      # Returns the map of defined attributes for this model class. The keys are attribute symbols and the values are
      # the attribute classes (or +nil+, indicating that the attribute is of a primitive type).
      #
      # @return [Hash<Symbol, Class>]
      # @since 1.0
      def api_attrs
        @api_attrs
      end
    end

    # Adds one or more defined attributes for this model class.
    #
    # If the first argument is a +Hash+, then its entries are added directly to the defined attributes map.
    # Otherwise, each argument is taken to be the name of a primitive-typed attribute. In either case,
    # {::Module#attr_accessor} is called for each attribute.
    #
    # @return [void]
    # @since 1.0
    def self.api_attr(*names)
      @api_attrs ||= {}
      if ! names.empty? && names.first.is_a?(Hash)
        names.first.each_pair do |name, clazz|
          @api_attrs[name.to_sym] = clazz
          attr_accessor(name.to_sym)
        end
      else
        names.each do |name|
          @api_attrs[name.to_sym] = nil
          attr_accessor(name.to_sym)
        end
      end
    end

    # Returns a list of URL query parameters computed by examining +options+ for entries related to +name+.
    #
    # This method encapsulates the "include/exclude" pattern for query parameters that filter model queries. For
    # example, stories queries take the +keyword+ and +no-keyword+ parameters to include or exclude stories
    # containing the parameter values in their titles, summaries or tags.
    #
    # A parameter named +#{name}+ is added when the options hash contains that key. A parameter named
    # +no-#{name}+ is added when the options hash contains that key or the key +wo-#{name}+ (the form used by
    # the Thor tasks, which reserve the "no-" prefix for a different purpose).
    #
    # Example:
    #
    #   >> OI::Base.multi_params(:keyword, 'no-keyword' => ['crime'], 'keyword' => ['kittens', 'socks'])
    #   => ["keyword=kittens", "keyword=socks", "no-keyword=crime"]
    #
    # @param [Symbol] name the base name of the query parameter
    # @param [Hash<String, Array<String>>] options the options which are examined for query parameter names
    # @return [Hash[String]]
    # @since 1.0
    def self.filter_params(name, options)
      params = []
      params.concat(options[name.to_s].map {|s| "#{name}=#{URI.escape(s)}"}) if options.include?(name.to_s)
      ["wo-#{name}", "no-#{name}"].each do |key|
        params.concat(options[key].map {|s| "no-#{name}=#{URI.escape(s)}"}) if options.include?(key)
      end
      params
    end

    # Calls the remote API service and returns the data encapsulated in the response.
    #
    # Uses {OI::Base#sign_url} to compute the signed absolute URL of the API resource.
    #
    # @param [String] relative_url the URL path relative to the version-identifier path component of the base
    #   service URL
    # @return [Object] the returned data structure as defined by the API specification (as parsed from the JSON
    #   envelope)
    # @raise [OI::ForbiddenException] for a +403+ response
    # @raise [OI::NotFoundException] for a +404+ response
    # @raise [OI::ServiceException] for any error response that indicates a service fault of some type
    # @raise [OI::ApiException] for any error response that indicates an invalid request or other client-side error
    # @since 1.0
    def self.call_remote(relative_url)
      url = sign_url(relative_url)
      OI.logger.debug("Requesting #{url}") if OI.logger
      response = HTTParty.get(url)
      unless response.code < 300
        raise ForbiddenException if response.code == 403
        raise NotFoundException if response.code == 404
        if response.headers.include?('x-mashery-error-code')
          raise ServiceException, response.headers['x-mashery-error-code']
        else
          data = JSON[response.body]
          msg = []
          if data.include?('error')
            msg << data['error']
          elsif data.include?('errors')
            msg.concat(data['errors'])
          else
            msg << 'unknown error'
          end
          raise ApiException, msg.join('; ')
        end
      end
      JSON[response.body]
    end

    # Returns the signed, absolutized form of +url+. 
    #
    # If +url+ begins with +/+ then the base service URL is prepended to it. The +dev_key+ and +sig+ query parameters
    # are appended to the query string.
    #
    # @param [String] url a URL to be signed and potentially absolutized
    # @return [String] the signed absolute URL
    # @since 1.0
    def self.sign_url(url)
      raise SignatureException, "Key not set" unless OI.key
      raise SignatureException, "Secret not set" unless OI.secret
      sig_params = "dev_key=#{OI.key}&sig=#{MD5.new(OI.key + OI.secret + Time.now.to_i.to_s).hexdigest}"
      signed = if url =~ /\?/
        "#{url}&#{sig_params}"
      else
        "#{url}?#{sig_params}"
      end
      signed =~ /^\// ? "http://#{HOST}/v#{VERSION}#{signed}" : signed
    end

    # Returns a new instance.
    #
    # Each entry of +attrs+ whose key identifies a defined model attribute is used to set the value of that
    # attribute. If the attribute's type is a +Class+, then an instance of that class is created with the raw
    # value passed to its initializer. Otherwise, the raw value is used directly.
    #
    # @param [Hash<Symbol, Object>] attrs the data used to initialize the model's attributes
    # @return [OI::Base]
    # @since 1.0
    def initialize(attrs = {})
      self.class.api_attrs.each_pair do |name, clazz|
        str = name.to_s
        if attrs.include?(str)
          v = attrs[str]
          val = if v.is_a?(Array)
            v.map {|it| clazz.nil?? it : clazz.new(it)}
          else
            clazz.nil?? v : clazz.new(v)
          end
          instance_variable_set("@#{str}".to_sym, val)
        end
      end
    end
  end
end
