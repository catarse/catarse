class ChangePostRewardToNotNull < ActiveRecord::Migration
  def change
    change_column_null(:post_rewards, :project_post_id, false)
    change_column_null(:post_rewards, :reward_id, false)
  end
end
