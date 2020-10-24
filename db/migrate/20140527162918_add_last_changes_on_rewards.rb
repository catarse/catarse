class AddLastChangesOnRewards < ActiveRecord::Migration[4.2]
  def change
    add_column :rewards, :last_changes, :text
  end
end
