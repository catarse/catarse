class RemoveNotNullFromBank < ActiveRecord::Migration
  def change
    change_column :project_accounts, :bank_id, :integer, null: true
  end
end
