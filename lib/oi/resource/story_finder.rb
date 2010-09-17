module OI
  module Resource
    # A resource that performs queries for stories.
    #
    # @since 1.0
    class StoryFinder < OI::Resource::Base
      QP = QueryParams.new({:limit => :limit, :'max-age' => :max_age}, {:keyword => :keyword, :vertical => :vertical,
        :format => :format, :'author-type' => :'author-type'})

      # Returns a version of +url+ that includes publication scoping when +inputs+ contains a non-nil
      # +publication-id+ entry.
      #
      # @param (see Resource#scope)
      # @return [String] the potentially scoped URL
      # @since 1.0
      def self.scope(url, inputs)
        inputs['publication-id'].nil?? url : url.gsub(/\/stories$/,
          "/publications/#{inputs['publication-id']}/stories")
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
