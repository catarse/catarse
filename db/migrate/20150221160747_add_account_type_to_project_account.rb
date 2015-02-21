class AddAccountTypeToProjectAccount < ActiveRecord::Migration
  def change
    add_column :project_accounts, :account_type, :text
  end
end
