class RenameConfigurationsToSettings < ActiveRecord::Migration
  def change
    execute "
    ALTER TABLE configurations RENAME TO settings;
    "
  end
end
