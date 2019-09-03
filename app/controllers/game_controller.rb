class GameController < ApplicationController
    def selection
      payload = JSON.parse params[:payload]
      puts payload['channel']['id']

      if payload['type'] == 'interactive_message'
        attachment = payload['original_message']['attachments'].first
        answer = attachment['actions'].find {|action| action['value'] == '1'}
        
        if payload['actions'].first['value'] == '1'  
          result = {
            replace_original: false,
            text: '✅ Good job! That was ' + answer['text']
          }
        else
          result = {
            replace_original: false,
            text: '❌ Nope! That was ' + answer['text']
          }
        end
      end
      Thread.new do # TODO call an AWS Lambda method to execute 
        sleep(1)
        FaceMatch::SlackHelper.play(payload['user'], payload['channel']['id'])
      end
      render json: result
    end
end
