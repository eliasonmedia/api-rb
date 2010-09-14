module OI
  class Location < Base
    api_attr :category, :city, :display_name, :lat, :lng, :state, :state_abbrev, :url, :url_name, :uuid
    # XXX: denote that category is a model too

    def self.named(name)
      data = call_remote("/locations/named/#{name}")
      rv = {:total => data['total'], :locations => []}
      data['locations'].each do |ld|
        rv[:locations] << new(ld)
      end
      rv
    end
  end
end
