class AddAccountTypeToBankAccounts < ActiveRecord::Migration[4.2]
  def change
    add_column :bank_accounts, :account_type, :text, default: 'conta_corrente'
  end
end
