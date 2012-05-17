class RenameAdvertVideosToInstitutionalVideos < ActiveRecord::Migration
  def self.up
    if ActiveRecord::Base.connection.tables.include?("advert_videos")
      rename_table :advert_videos, :institutional_videos
    end
  end

  def self.down
    if ActiveRecord::Base.connection.tables.include?("institutional_videos")
      rename_table :institutional_videos, :advert_videos
    end
  end
end
