module OI
  class Category < Base
    api_attr :name, :display_name

    def to_s
      display_name
    end
  end
end
