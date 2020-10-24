class FixDefaultPermalink < ActiveRecord::Migration[4.2]
  def change
    execute <<-SQL
    alter table projects
      alter column permalink set default concat('project_', currval('projects_id_seq'));

    SQL
  end
end
