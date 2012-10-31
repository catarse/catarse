class AddVideoThumbnailToProject < ActiveRecord::Migration
  def change
    add_column :projects, :video_thumbnail, :text
  end
end
