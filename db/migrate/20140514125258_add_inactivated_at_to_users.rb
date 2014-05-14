class AddInactivatedAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :deactivated_at, :timestamp
  end
end
