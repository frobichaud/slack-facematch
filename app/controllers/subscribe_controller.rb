class SubscribeController < ApplicationController
  def create
    return render json: {}, status: 401 unless params[:event]

    unless params[:event][:bot_id]
      profile = FaceMatch::SlackHelper.fetch_profiles(params[:event][:user])
      FaceMatch::SlackHelper.send_quiz_message(profile, params[:event][:channel])
      # unless params[:event][:bot_id]
      #   client.chat_postMessage(channel: params[:event][:channel], text: params[:event][:text], as_user: true)
      # end
    end
    render json: {}
  end
end
