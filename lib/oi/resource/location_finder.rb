module OI
  module Resource
    # A resource that performs queries for locations.
    #
    # @since 1.0
    class LocationFinder < OI::Resource::Base
      QP = QueryParams.new({:limit => :limit}, {:category => :category})

      # Returns a version of +url+ that includes publication scoping when +inputs+ contains a non-nil
      # +publication-id+ entry.
      #
      # @param (see Resource#scope)
      # @return [String] the potentially scoped URL
      # @since 1.0
      def self.scope(url, inputs)
        inputs['publication-id'].nil?? url : "#{url}/publications/#{inputs['publication-id']}"
      end

      # Returns a version of +url+ with parameters in the query string corresponding to +inputs+.
      #
      # @param (see Resource#scope)
      # @return [String] the URL including query parameters
      # @since 1.0
      def self.parameterize(url, inputs)
        QP.parameterize(url, inputs)
      end
    end
  end
end
