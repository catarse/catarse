class CreateAdvertVideos < ActiveRecord::Migration
  def self.up
    create_table :advert_videos do |t|
      t.string :title
      t.text :description
      t.string :video_url
      t.boolean :visible

      t.timestamps
    end
  end

  def self.down
    drop_table :advert_videos
  end
end
