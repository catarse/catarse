class RenameConfigurationsToSettings < ActiveRecord::Migration[4.2]
  def change
    execute "
    ALTER TABLE configurations RENAME TO settings;
    "
  end
end
