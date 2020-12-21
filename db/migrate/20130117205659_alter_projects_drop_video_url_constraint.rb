class AlterProjectsDropVideoUrlConstraint < ActiveRecord::Migration[4.2]
  def up
    execute "
    ALTER TABLE projects ALTER video_url DROP NOT NULL;
    ALTER TABLE projects DROP CONSTRAINT projects_video_url_not_blank;
    "
  end

  def down
    execute "
    ALTER TABLE projects ALTER video_url SET NOT NULL;
    ALTER TABLE projects ADD CONSTRAINT projects_video_url_not_blank CHECK(video_url <> '');
    "
  end
end
