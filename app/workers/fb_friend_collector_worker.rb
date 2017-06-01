# frozen_string_literal: true

class FbFriendCollectorWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, queue: 'actions'

  def perform(authorization_id)
    if auth = Authorization.find(authorization_id) # yep is assign ;)
      user_friends = auth.user.user_friends
      last_friend = user_friends.order('id DESC').first

      return if last_friend && last_friend.created_at > 24.hours.ago

      koala = Koala::Facebook::API.new(auth.last_token)

      userlink = koala.get_object('me') { |data| data['link'] }
      friends = koala.get_connections('me', 'friends')
      friendsCount = friends.raw_response['summary'].try(:[], 'total_count')

      lastFriendCount = SocialFollower.where({ user_id: auth.user.id, profile_type: 'fb_profile' }).order('created_at').last.try(:followers)

      unless lastFriendCount == friendsCount
        SocialFollower.create({ user_id: auth.user.id, username: userlink, profile_type: 'fb_profile', followers: friendsCount })
      end

      friends.each do |f|
        if friend = Authorization.find_by_uid(f['id']).try(:user)
          user_friends.create(friend: friend)
        end
      end
    end
  end
end
