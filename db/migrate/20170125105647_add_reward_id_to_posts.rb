class AddRewardIdToPosts < ActiveRecord::Migration[4.2]
  def change
    add_reference :project_posts, :reward, index: true
  end
end
