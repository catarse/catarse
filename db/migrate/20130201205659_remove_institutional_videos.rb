class RemoveInstitutionalVideos < ActiveRecord::Migration
  def up
    drop_table :institutional_videos
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
