class CreateUserFriends < ActiveRecord::Migration
  def change
    create_table :user_friends do |t|
      t.integer :user_id
      t.integer :friend_id, foreign_key: { references: :users }

      t.timestamps
    end

    add_index :user_friends, [:user_id, :friend_id], unique: true
  end
end
