class AddedPublishedAtIntoPosts < ActiveRecord::Migration
  def change
    add_column :channel_posts, :published_at, :datetime
  end
end
