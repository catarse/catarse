class CreatePostRewards < ActiveRecord::Migration[4.2]
  def change
    create_table :post_rewards do |t|
      t.references :project_post, index: true, foreign_key: true
      t.references :reward, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
