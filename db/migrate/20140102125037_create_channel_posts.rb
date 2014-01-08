class CreateChannelPosts < ActiveRecord::Migration
  def change
    create_table :channel_posts do |t|
      t.text :title
      t.text :body
      t.text :body_html
      t.references :channel, index: true
      t.references :user, index: true
      t.boolean :visible

      t.timestamps
    end
  end
end
