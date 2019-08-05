class GameController < ApplicationController
    def selection
      payload = JSON.parse params[:payload]
      puts payload
      puts payload
      puts payload
      if payload['type'] == 'interactive_message'
        #TODO verify success/failure
        #if payload[:actions].any?()
        puts 'zzzzz'
        #FaceMatch::SlackHelper.reply_success(event[:channel], 'TODO')
      end
      json: {replace_original: false}
    end
end
