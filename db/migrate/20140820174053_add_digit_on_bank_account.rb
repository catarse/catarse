class AddDigitOnBankAccount < ActiveRecord::Migration
  def change
    add_column :bank_accounts, :account_digit, :text, null: false
    add_column :bank_accounts, :agency_digit, :text, null: false
  end
end
