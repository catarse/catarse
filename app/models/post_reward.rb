class PostReward < ActiveRecord::Base
  belongs_to :project_post
  belongs_to :reward
end
