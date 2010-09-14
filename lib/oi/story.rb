module OI
  class Story < Base
    api_attr :feed_title, :feed_url, :story_url, :summary, :title, :uuid
    api_attr :tags => Tag

    def self.for_state(state)
      query_result(call_remote("/states/#{URI.escape(state)}/stories"))
    end

    def self.for_city(state, city)
      query_result(call_remote("/states/#{URI.escape(state)}/cities/#{URI.escape(city)}/stories"))
    end

    def self.for_nabe(state, city, nabe)
      query_result(call_remote(
        "/states/#{URI.escape(state)}/cities/#{URI.escape(city)}/nabes/#{URI.escape(nabe)}/stories"))
    end

    def self.for_zip_code(zip)
      query_result(call_remote("/zipcodes/#{URI.escape(zip)}/stories"))
    end

    def self.for_uuids(uuids)
      query_result(call_remote("/locations/#{uuids.map{|u| URI.escape(u)}.join(",")}/stories"))
    end

    def to_s
      "#{title} (#{uuid})"
    end

  protected
    def self.query_result(data)
      rv = {:total => data['total'], :stories => []}
      if data.include?('locations')
        rv[:locations] = data['locations'].map {|l| Location.new(l)}
      else
        rv[:location] = Location.new(data['location'])
      end
      rv[:stories] = data['stories'].map {|s| new(s)}
      rv
    end
  end
end
