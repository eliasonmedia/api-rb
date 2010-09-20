module OutsideIn
  # Topic tag model class. Tags are attached to stories to provide hints for content and relevance. Keyword queries
  # match against tags as well as story title and summary.
  #
  # Tags have the following attributes:
  #
  # * name
  #
  # @since 1.0
  class Tag < Base
    api_attr :name

    # Returns the tag's name.
    #
    # @return [String]
    # @since 1.0
    def to_s
      name
    end
  end
end
