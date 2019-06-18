require 'json'

module Lambda
  class Handlers
    def self.register(event:, context:)
      { statusCode: 200, body: JSON.generate( {} ) }
    end
  end
end
