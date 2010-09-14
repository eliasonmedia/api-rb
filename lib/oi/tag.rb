module OI
  class Tag < Base
    api_attr :name

    def to_s
      name
    end
  end
end
