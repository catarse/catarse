class AddOtherOnStates < ActiveRecord::Migration
  def up
    execute "INSERT INTO states (name, acronym, created_at, updated_at) VALUES
      ('Outro / Other', 'outro/other', current_timestamp, current_timestamp)
    "
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
