require 'uri'

class FbPageCollectorWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, queue: 'actions'

  def perform
    users = User.where.not(facebook_link: [nil, ''])
    koala = Koala::Facebook::API.new("#{CatarseSettings[:fb_app_id]}|#{CatarseSettings[:fb_app_secret]}")

    users.each do |usr|
      path = URI(usr.facebook_link).path.split('/').last

      likes = koala.get_object(path) {|data| data['likes']} rescue nil
      unless likes.nil? || likes == 0
        SocialFollower.create({user_id: usr.id, username: path, profile_type: 'fb_page', followers: likes})
      end
    end

  end
end
