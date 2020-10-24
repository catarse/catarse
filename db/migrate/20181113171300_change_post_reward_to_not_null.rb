class ChangePostRewardToNotNull < ActiveRecord::Migration[4.2]
  def change
    change_column_null(:post_rewards, :project_post_id, false)
    change_column_null(:post_rewards, :reward_id, false)
  end
end
