class SubscribeController < ApplicationController
  def create
    client = Slack::Web::Client.new
    unless params[:event][:bot_id]
      client.chat_postMessage(channel: params[:event][:channel], text: params[:event][:text], as_user: true)
    end
    render json: {}
  end
end
