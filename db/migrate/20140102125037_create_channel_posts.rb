class CreateChannelPosts < ActiveRecord::Migration
  def change
    create_table :channel_posts do |t|
      t.text :title, null: false
      t.text :body, null: false
      t.text :body_html, null: false
      t.references :channel, index: true, null: false
      t.references :user, index: true, null: false
      t.boolean :visible, null: false, default: false

      t.timestamps
    end
  end
end
