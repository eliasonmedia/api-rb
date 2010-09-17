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
