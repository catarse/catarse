class RemoveUserFromProjectAccount < ActiveRecord::Migration[4.2]
  def change
    remove_column :project_accounts, :user_id
  end
end
