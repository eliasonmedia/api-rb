module OI
  class Story < Base
    api_attr :feed_title, :feed_url, :story_url, :summary, :tags, :title, :uuid
    # XXX: denote that tag is a list of Tags

    def self.for_state(state)
      data = call_remote("/states/#{state}/stories")
      rv = {:total => data['total'], :stories => []}
      data['stories'].each do |s|
        rv[:stories] << new(s)
      end
      rv
    end
  end
end
