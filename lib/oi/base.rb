require 'active_support/core_ext/class/attribute_accessors'
require 'httparty'
require 'json'
require 'md5'

module OI
  class Base
    cattr_accessor :api_attrs, :instance_writer => false
    @@api_attrs = {}

    cattr_accessor :api_attr_classes, :instance_writer => false
    @@api_attr_classes = {}

    def self.api_attr(*names)
      if ! names.empty? && names.first.is_a?(Hash)
        names.first.each_pair do |name, clazz|
          api_attrs[name] = clazz
          attr_reader(name)
        end
      else
        names.each do |name|
          api_attrs[name] = nil
          attr_reader(name)
        end
      end
    end

    def self.call_remote(relative_url)
      url = sign_url(relative_url)
      OI.logger.debug("Requesting #{url}") if OI.logger
      response = HTTParty.get(url)
      unless response.code < 300
        raise ForbiddenException if response.code == 403
        raise NotFoundException if response.code == 404
        if response.headers.include?('x-mashery-error-code')
          raise HttpException, response.headers['x-mashery-error-code']
        else
          data = JSON[response.body]
          raise ApiException, (data.include?('error') ? data['error'] : 'unknown error')
        end
      end
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
      api_attrs.each_pair do |name, clazz|
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
