class AddRewardIdToPosts < ActiveRecord::Migration
  def change
    add_reference :project_posts, :reward, index: true
  end
end
