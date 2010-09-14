require 'httparty'
require 'json'
require 'md5'

module OI
  class Client
    HOST = 'hyperlocal-api.outside.in'
    VERSION = '1.1'

    def initialize(key, secret)
      raise ArgumentError, "key is required" if key.nil?
      raise ArguemntError, "secret is required" if secret.nil?
      @base_url = "http://#{HOST}/v#{VERSION}"
      @key = key
      @secret = secret
    end

    def call_remote(relative_url)
      url = complete_url(relative_url)
      OI.logger.debug("Requesting #{url}") if OI.logger
      response = HTTParty.get(url)
      raise Exception, response.inspect unless response.code < 300
      JSON[response.body]
    end

    def complete_url(relative)
      sign_url(absolutize_url(relative))
    end

    def absolutize_url(relative)
      @base_url + relative
    end

    def sign_url(url)
      sig_params = "dev_key=#{@key}&sig=#{MD5.new(@key + @secret + Time.now.to_i.to_s).hexdigest}"
      if url =~ /\?/
        "#{url}&#{sig_params}"
      else
        "#{url}?#{sig_params}"
      end
    end
  end
end
