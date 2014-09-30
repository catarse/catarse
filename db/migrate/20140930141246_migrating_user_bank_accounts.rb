class MigratingUserBankAccounts < ActiveRecord::Migration
  def up
    add_column :bank_accounts, :bank_id, :integer
  end

  def down
    remove_column :bank_accounts, :bank_id
  end
end
