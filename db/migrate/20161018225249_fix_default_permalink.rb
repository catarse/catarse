class FixDefaultPermalink < ActiveRecord::Migration
  def change
    execute <<-SQL
    alter table projects
      alter column permalink set default concat('project_', currval('projects_id_seq'));

    SQL
  end
end
