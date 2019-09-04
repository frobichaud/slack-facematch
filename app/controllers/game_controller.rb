class GameController < ApplicationController
  def selection
    payload = JSON.parse params[:payload]

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
    # TODO: invoke the API Gateway to generate continous requests
    # if ENV['RACK_ENV'] != 'production'
    #   Thread.new {
    #     sleep(1)
    #     create_request(request.base_url, 'next_profile', payload['user'], payload['channel']['id'])
    #   }
    # else
    #   create_request(request.base_url, 'next_profile', payload['user'], payload['channel']['id'])
    # end
    render json: result
  end

  def next_profile
    user = params['user']
    channel = params['channelId']
    sleep(1)
    FaceMatch::SlackHelper.play(user, channel) if user && channel
    render json: {}
  end

  private
  def create_request(url, action, user, channel_id)
    uri = URI.parse("#{url}/#{action}")
    header = {'Content-Type': 'text/json'}
    body = {
      user: user,
      channelId: channel_id
    }
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body = body.to_json
    http.request(request)
  end
end
