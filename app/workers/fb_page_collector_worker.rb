require 'uri'

class FbPageCollectorWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform user
    path = URI(user.facebook_link).path.split('/').last

    koala = Koala::Facebook::API.new("#{CatarseSettings[:fb_app_id]}|#{CatarseSettings[:fb_app_secret]}")
    likes = koala.get_object(path) {|data| data['likes']} rescue nil

    unless likes.nil? || likes == 0
      SocialFollower.create({user_id: user.id, username: path, profile_type: 'fb_page', followers: likes})
    end
  end
end
