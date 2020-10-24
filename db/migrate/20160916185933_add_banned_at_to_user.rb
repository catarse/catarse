class AddBannedAtToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :banned_at, :datetime
  end
end
