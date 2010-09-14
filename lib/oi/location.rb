module OI
  class Location < Base
    api_attr :category, :city, :display_name, :lat, :lng, :state, :state_abbrev, :url, :url_name, :uuid
    # XXX: denote that category is a Category

    def self.named(name)
      query_result(call_remote("/locations/named/#{URI.escape(name)}"))
    end

  protected
    def query_result(data)
      rv = {:total => data['total'], :locations => []}
      data['locations'].each do |ld|
        rv[:locations] << new(ld)
      end
      rv
    end
  end
end
