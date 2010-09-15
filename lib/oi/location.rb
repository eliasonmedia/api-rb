module OI
  class Location < Base
    api_attr :city, :display_name, :lat, :lng, :state, :state_abbrev, :url, :url_name, :uuid
    api_attr :category => Category

    def self.named(name, options = {})
      url = "/locations/named/#{URI.escape(name)}"
      query_result(call_remote(parameterize_url(url, options)))
    end

    def to_s
      "#{display_name} (#{uuid})"
    end

  protected
    def self.parameterize_url(url, options)
      qs = []
      qs << "limit=#{options[:limit]}" if options.include?('limit')
      qs.concat(multi_params(:category, options))
      qs.empty?? url : "#{url}?#{qs.join('&')}"
    end

    def self.query_result(data)
      rv = {:total => data['total'], :locations => []}
      rv[:locations] = data['locations'].map {|l| new(l)}
      rv
    end
  end
end
