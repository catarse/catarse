class AddedPublishedAtIntoPosts < ActiveRecord::Migration[4.2]
  def change
    add_column :channel_posts, :published_at, :datetime
  end
end
