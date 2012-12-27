class DeleteOtherFromStates < ActiveRecord::Migration
  def up
    execute <<-SQL
      DELETE FROM states WHERE name = 'Outro / Other';
    SQL
  end

  def down
    execute "INSERT INTO states (name, acronym, created_at, updated_at) VALUES
      ('Outro / Other', 'outro/other', current_timestamp, current_timestamp)
    "
  end
end
