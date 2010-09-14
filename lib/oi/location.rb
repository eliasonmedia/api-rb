module OI
  class Location < Base
    api_attr :city, :display_name, :lat, :lng, :state, :state_abbrev, :url, :url_name, :uuid
    api_attr :category => Category

    def self.named(name)
      query_result(call_remote("/locations/named/#{URI.escape(name)}"))
    end

    def to_s
      "#{display_name} (#{uuid})"
    end

  protected
    def query_result(data)
      rv = {:total => data['total'], :locations => []}
      rv[:locations] = data['locations'].map {|l| new(l)}
      rv
    end
  end
end
