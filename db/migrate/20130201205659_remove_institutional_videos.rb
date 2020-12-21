class RemoveInstitutionalVideos < ActiveRecord::Migration[4.2]
  def up
    drop_table :institutional_videos
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
