class AddAccountTypeToProjectAccount < ActiveRecord::Migration[4.2]
  def change
    add_column :project_accounts, :account_type, :text
  end
end
