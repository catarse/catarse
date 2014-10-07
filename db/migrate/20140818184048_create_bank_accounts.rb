class CreateBankAccounts < ActiveRecord::Migration
  def change
    create_table :bank_accounts do |t|
      t.references :user, index: true
      t.text :name, null: false
      t.text :account, null: false
      t.text :agency, null: false
      t.text :owner_name, null: false
      t.text :owner_document, null: false

      t.timestamps
    end
  end
end
