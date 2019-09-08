module FaceMatch
  class SlackHelper
    
    @client = Slack::Web::Client.new
    @cache = SlackCache.new(@client)

    def self.fetch_profiles(current_user_id)
      profiles = generate_profiles(current_user_id)
      results = profiles.map.with_index do |profile, index|
        {
          id: profile['id'],
          name: profile['profile']['real_name'],
          picture: profile['profile']['image_192'],
          title: profile['profile']['title'],
          answer: index == 0 ? 'true' : 'false'
        }
      end
      results
    end

    def self.send_quiz_message(profiles, channel)
      @client.chat_postMessage(channel: channel,
                                        blocks: [
                                          {
                                            type: 'section',
                                            text: {
                                              text: '*WHO DIS?*',
                                              type: 'mrkdwn'
                                            }
                                          },
                                          {
                                            type: 'image',
                                            image_url: profiles.find {|p| p[:answer]}[:picture],
                                            alt_text: 'Random'
                                          },
                                          {
                                            type: 'actions',
                                            block_id: 'profiles',
                                            elements: profiles.shuffle.map do |profile| 
                                              {
                                                type: 'button',                                                  
                                                text: {
                                                  type: 'plain_text',
                                                  text: profile[:name],
                                                },
                                                value: profile[:answer]
                                              }
                                            end
                                          },
                                          {
                                            type: 'divider'
                                          },
                                          {
                                            type: 'actions',
                                            block_id: 'next',
                                            elements: [
                                              {
                                                type: 'button',
                                                text: {
                                                  type: 'plain_text',
                                                  text: 'Next'
                                                },
                                                style: "primary",
                                                value: 'next'
                                              }
                                            ]
                                          }
                                        ]
                                      )
    end

    def self.help(channel)
      @client.chat_postMessage(channel: channel,
                                        as_user: true,
                                        text: 'Type "go" to receive a random profile picture challenge')
    end

    def self.play(current_user_id, channel)
      profiles = FaceMatch::SlackHelper.fetch_profiles(current_user_id)
      FaceMatch::SlackHelper.send_quiz_message(profiles, channel)
    end

    private
    def self.generate_profiles(current_user_id)
      members = @cache.users
      filtered_user_ids = [current_user_id]
      results = []
      4.times.each do
        match = filter_selection(filtered_user_ids, members)
        results << match
        filtered_user_ids << match['id']
      end
      results
    end

    def self.filter_selection(user_filter, members)
      member = members[rand(0...members.count)]
      # Skip invalid user profiles
      if (member['is_bot'] || 
          user_filter.include?(member[:id]) || 
          member['id'] == 'USLACKBOT' || 
          member['profile']['image_192'].nil? || 
          member['is_app_user'] ||
          member['deleted'] ||
          member['is_restricted']
        )
        member = filter_selection(user_filter, members)
      end
      member
    end
  end
end
