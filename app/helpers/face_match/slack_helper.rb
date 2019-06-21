module FaceMatch
  class SlackHelper

    @client = Slack::Web::Client.new
    @@DEBUG = true

    def self.fetch_profiles(current_user)
      profile = random_profile(current_user)
      {
        name: profile.real_name,
        picture: profile.image_512
      }
    end

    def self.send_quiz_message(selected_profile, channel)
      @client.chat_postMessage(channel: channel,
                                        as_user: true,
                                        text: 'WHO DIS?',
                                        attachments: [{
                                            type: 'image',
                                            title: {},
                                            image_url: selected_profile[:picture],
                                            attachment_type: "default",
                                            actions: [{
                                              name: 'first',
                                              text: selected_profile[:name],
                                              type: 'button',
                                              value: '0'
                                            }]
                                          }
                                        ])
    end

    private
    def self.random_profile(current_user)
      members = @client.users_list[:members]
      random_pick = rand(0...members.count)
      profile = members[random_pick]
      puts '#####'
      puts profile.is_bot
      puts profile[:id]
      puts current_user
      puts '#####'
      # Skip bots, avoid the current_user and make sure there's a picture
      if (profile.is_bot || profile[:id] == current_user || profile[:id] == 'USLACKBOT' || profile[:picture].nil?) && !@@DEBUG
        profile = random_profile(current_user) #TODO: if no user have profile picture, we'll end up with an infinite loop until Slack::Web::Api::Errors::TooManyRequestsError
      end
      profile
    end
  end
end
