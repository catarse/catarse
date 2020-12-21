class RemoveNotNullFromBank < ActiveRecord::Migration[4.2]
  def change
    change_column :project_accounts, :bank_id, :integer, null: true
  end
end
