module FaceMatch
  class SlackHelper

    @client = Slack::Web::Client.new
    @@DEBUG = true

    def self.fetch_profiles(current_user)
      profiles = generate_profiles(current_user)
      results = profiles.map.with_index do |profile, index|
        {
          id: profile.id,
          name: profile.profile.real_name,
          picture: profile.profile.image_192,
          answer: index == 0
        }
      end
      results.shuffle
    end

    def self.send_quiz_message(profiles, channel)
      @client.chat_postMessage(channel: channel,
                                        as_user: true,
                                        text: 'WHO DIS?',
                                        attachments: [{
                                          type: 'image',
                                          title: {},
                                          image_url: profiles.first[:picture],
                                          attachment_type: "default",
                                          callback_id: 'name',
                                          actions: profiles.map do |profile| 
                                            {
                                              name: profile[:id],
                                              text: profile[:name],
                                              type: 'button',
                                              value: profile[:answer]
                                            }
                                          end
                                        }
                                        ])
    end

    def self.help(channel)
      @client.chat_postMessage(channel: channel,
                                        as_user: true,
                                        text: 'Type "play" to receive a random profile picture challenge. "sync" if you need to force updating the organization user list.')
    end


    def self.reply_failure(answer, channel)
      @client.chat_postMessage(channel: channel,
                                        as_user: true,
                                        text: '‼Wrong pick‼, that was ' + answer)
    end

    private
    def self.generate_profiles(current_user)
      members = @client.users_list[:members]
      first_rnd = members[rand(0...members.count)]
      second_rnd = members[rand(0...members.count)]
      selection = pick_selection([current_user, first_rnd.id, second_rnd.id], members)      
      [selection, first_rnd, second_rnd]
    end

    def self.pick_selection(user_filter, members)
      member = members[rand(0...members.count)]
      # Skip bots, avoid the current_user and make sure there's a picture
      if (member.is_bot || user_filter.include?(member[:id]) || member[:id] == 'USLACKBOT' || member.profile[:image_192].nil?) && !@@DEBUG
        profile = pick_selection(user_filter, members) #TODO: if no user have profile picture, we'll end up with an infinite loop until Slack::Web::Api::Errors::TooManyRequestsError
      end
      member
    end
  end
end
