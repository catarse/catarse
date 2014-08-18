class CreateBankAccounts < ActiveRecord::Migration
  def change
    create_table :bank_accounts do |t|
      t.references :user, index: true
      t.text :name
      t.text :account
      t.text :agency
      t.text :user_name
      t.text :user_document

      t.timestamps
    end
  end
end
