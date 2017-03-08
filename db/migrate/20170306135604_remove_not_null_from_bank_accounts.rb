class RemoveNotNullFromBankAccounts < ActiveRecord::Migration
  def change
    change_column_null :bank_accounts, :owner_name, :true
    change_column_null :bank_accounts, :owner_document, :true
  end
end
