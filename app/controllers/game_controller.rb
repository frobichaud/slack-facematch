class GameController < ApplicationController
  def selection
    payload = JSON.parse params[:payload]
    result = {}

    if payload['type'] == 'block_actions'
      action = payload['actions'].first
      if action['block_id'] == 'next'
        next_profile(payload['user']['id'], payload['channel']['id'])

      elsif action['block_id'] == 'profiles'
        validate_answer(action, payload['message'], payload['response_url'])
      end
    end

    render json: result
  end

  private
  def next_profile(user, channel)
    FaceMatch::SlackHelper.play(user, channel) if user && channel
  end

  def validate_answer(action, message, response_url)
    if action['value'] == 'true'
      text = '✅ Good job! That was ' + action['text']['text']
    else
      profiles = message['blocks'].find {|b| b['block_id'] == 'profiles'}['elements']
      answer = profiles.find {|p| p['value'] == 'true'}
      text = '❌ Nope! That was ' + answer['text']['text']
    end
    create_request(response_url, text)
  end

  def create_request(url, text)
    uri = URI.parse(url)
    header = {'Content-Type': 'text/json'}
    body = {
      text: text,
      'replace_original': false,
      'delete_original': false
    }
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body = body.to_json
    http.request(request)
  end
end
