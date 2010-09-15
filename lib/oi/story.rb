module OI
  class Story < Base
    api_attr :feed_title, :feed_url, :story_url, :summary, :title, :uuid
    api_attr :tags => Tag

    def self.for_state(state, options = {})
      url = "/states/#{URI.escape(state)}/stories"
      query_result(call_remote(parameterize_url(url, options)))
    end

    def self.for_city(state, city, options = {})
      url = "/states/#{URI.escape(state)}/cities/#{URI.escape(city)}/stories"
      query_result(call_remote(parameterize_url(url, options)))
    end

    def self.for_nabe(state, city, nabe, options = {})
      url = "/states/#{URI.escape(state)}/cities/#{URI.escape(city)}/nabes/#{URI.escape(nabe)}/stories"
      query_result(call_remote(parameterize_url(url, options)))
    end

    def self.for_zip_code(zip, options = {})
      url = "/zipcodes/#{URI.escape(zip)}/stories"
      query_result(call_remote(parameterize_url(url, options)))
    end

    def self.for_uuids(uuids, options = {})
      url = "/locations/#{uuids.map{|u| URI.escape(u)}.join(",")}/stories"
      query_result(call_remote(parameterize_url(url, options)))
    end

    def to_s
      "#{title} (#{uuid})"
    end

  protected
    def self.parameterize_url(url, options)
      qs = []
      qs << "limit=#{options[:limit]}" if options.include?('limit')
      qs << "max_age=#{URI.escape(options[:'max-age'])}" if options.include?('max-age')
      qs.concat(multi_params(:keyword, options))
      qs.concat(multi_params(:vertical, options))
      qs.concat(multi_params(:format, options))
      qs.concat(multi_params(:'author-type', options))
      qs.empty?? url : "#{url}?#{qs.join('&')}"
    end

    def self.multi_params(key, options)
      params = []
      params.concat(options[key].map {|s| "#{key}=#{URI.escape(s)}"}) if options.include?(key.to_s)
      params.concat(options["wo-#{key}"].map {|s| "no-#{key}=#{URI.escape(s)}"}) if options.include?("wo-#{key}")
      params
    end

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
