class AddAccountTypeToBankAccounts < ActiveRecord::Migration
  def change
    add_column :bank_accounts, :account_type, :text, default: 'conta_corrente'
  end
end
