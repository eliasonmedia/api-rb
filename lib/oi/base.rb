require 'active_support/core_ext/class/attribute_accessors'
require 'httparty'
require 'json'
require 'md5'

module OI
  class Base
    cattr_accessor :api_attrs, :instance_writer => false
    @@api_attrs = []

    def self.api_attr(*names)
      api_attrs.concat(names)
      names.each {|n| attr_accessor(n)}
    end

    def self.call_remote(relative_url)
      url = sign_url(relative_url)
      OI.logger.debug("Requesting #{url}") if OI.logger
      response = HTTParty.get(url)
      raise ForbiddenException if response.code == 403
      raise NotFoundException if response.code == 404
      raise Exception, response.headers['x-mashery-error-code'] unless response.code < 300
      JSON[response.body]
    end

    def self.sign_url(url)
      sig_params = "dev_key=#{OI.key}&sig=#{MD5.new(OI.key + OI.secret + Time.now.to_i.to_s).hexdigest}"
      signed = if url =~ /\?/
        "#{url}&#{sig_params}"
      else
        "#{url}?#{sig_params}"
      end
      signed =~ /^\// ? "http://#{HOST}/v#{VERSION}#{signed}" : signed
    end

    def initialize(attrs = {})
      api_attrs.each do |aa|
        name = aa.to_s
        send("#{aa}=", attrs[name]) if attrs.include?(name)
      end
    end
  end
end
