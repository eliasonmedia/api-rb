module OI
  class Story < Base
    api_attr :feed_title, :feed_url, :story_url, :summary, :tags, :title, :uuid
    # XXX: denote that tag is a list of Tags

    def self.for_state(state)
      query_result(call_remote("/states/#{URI.escape(state)}/stories"))
    end

    def self.for_city(state, city)
      query_result(call_remote("/states/#{URI.escape(state)}/cities/#{URI.escape(city)}/stories"))
    end

    def self.for_nabe(state, city, nabe)
      query_result(call_remote("/states/#{URI.escape(state)}/cities/#{URI.escape(city)}/nabes/#{URI.escape(nabe)}/stories"))
    end

    def self.for_zip_code(zip)
      query_result(call_remote("/zipcodes/#{URI.escape(zip)}/stories"))
    end

  protected
    def self.query_result(data)
      rv = {:total => data['total'], :stories => []}
      data['stories'].each do |s|
        rv[:stories] << new(s)
      end
      rv
    end
  end
end
