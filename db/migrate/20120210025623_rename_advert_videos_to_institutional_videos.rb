class RenameAdvertVideosToInstitutionalVideos < ActiveRecord::Migration
  def self.up
    rename_table :advert_videos, :institutional_videos
  end

  def self.down
    rename_table :institutional_videos, :advert_videos
  end
end
