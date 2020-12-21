class RemoveNotNullFromBankAccounts < ActiveRecord::Migration[4.2]
  def change
    change_column_null :bank_accounts, :owner_name, :true
    change_column_null :bank_accounts, :owner_document, :true
  end
end
