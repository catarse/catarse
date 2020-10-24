class RemoveNicknameFromUsers < ActiveRecord::Migration[4.2]
  def change
    remove_column :users, :nickname, :text
  end
end
