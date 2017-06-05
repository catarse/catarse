# frozen_string_literal: true

require 'uri'

class FbPageCollectorWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(user_id)
    user = User.where("users.id=? and users.fb_parsed_link~'^pages/\\d+$'", user_id).first
    unless user.nil?
      path = user.fb_parsed_link.split('/').last
      koala = Koala::Facebook::API.new("#{CatarseSettings[:fb_app_id]}|#{CatarseSettings[:fb_app_secret]}")
      likes = begin
                koala.get_object(path, {}, api_version: 'v2.3') { |data| data['likes'] }
              rescue
                nil
              end

      if likes.present? && likes >= 0
        SocialFollower.create({ user_id: user.id, username: path, profile_type: 'fb_page', followers: likes })
      end
    end
  end
end
