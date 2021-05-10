class AddIndexToProjectIntegrationNameAndData < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL

    CREATE UNIQUE INDEX project_integrations_idx ON project_integrations(name, (data->>'draft_url'), project_id);

    SQL
  end

  def down
    execute <<-SQL

    DROP INDEX project_integrations_idx;

    SQL
  end
end
