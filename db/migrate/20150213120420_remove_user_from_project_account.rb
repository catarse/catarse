class RemoveUserFromProjectAccount < ActiveRecord::Migration
  def change
    remove_column :project_accounts, :user_id
  end
end
