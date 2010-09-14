require 'active_support/core_ext/class/attribute_accessors'

module OI
  class Base
    cattr_accessor :api_attrs, :instance_writer => false
    @@api_attrs = []

    def self.api_attr(*names)
      api_attrs.concat(names)
      names.each {|n| attr_accessor(n)}
    end

    def initialize(attrs = {})
      api_attrs.each do |aa|
        name = aa.to_s
        send("#{aa}=", attrs[name]) if attrs.include?(name)
      end
    end
  end
end
