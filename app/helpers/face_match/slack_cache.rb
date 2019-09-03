module FaceMatch
  class SlackCache
    PAGE_LIMIT = 200

    def initialize(client)
      @client = client
      @cache = Redis.new(url: ENV['REDIS_URL'])
    end

    def users
      get('users') {
        members = [] 
        @client.users_list(limit: PAGE_LIMIT) { |response| members += response.members}
        members.to_json
      }
    end

    private
    # Retrieves items from the cache else invokes the API
    def get(key)
      values = @cache.get(key)
      unless values
        values = yield
        @cache.setex(key, 1.hour, values)
      end
      JSON.parse values
    end
  end
end