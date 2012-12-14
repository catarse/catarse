class AddUserPrimaryUserIdProviderIndex < ActiveRecord::Migration
  def up
    add_index :users, [:primary_user_id, :provider]
  end

  def down
    remove_index :users, [:primary_user_id, :provider]
  end
end
