class PostReward < ApplicationRecord
  belongs_to :project_post
  belongs_to :reward
end
