class AddLastChangesOnRewards < ActiveRecord::Migration
  def change
    add_column :rewards, :last_changes, :text
  end
end
