module OutsideIn
  # Category model class. Each location has a category that describes its places in the location hierachy, e.g
  # state, city, neighborhood, zip code, etc.
  #
  # Categories have the following attributes:
  #
  # * display_name
  # * name
  #
  # @since 1.0
  class Category < Base
    api_attr :name, :display_name

    # Returns the category's display name.
    #
    # @return [String]
    # @since 1.0
    def to_s
      display_name
    end
  end
end
