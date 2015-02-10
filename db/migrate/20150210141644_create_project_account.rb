class CreateProjectAccount < ActiveRecord::Migration
  def change
    create_table :project_accounts do |t|
      t.references :user, index: true, null: false
      t.references :project, index: true, null: false
      t.references :bank, index: true, null: false
      t.text :full_name, null: false
      t.text :email, null: false
      t.text :cpf, null: false
      t.text :state_inscription
      t.text :address_street, null: false
      t.text :address_number, null: false
      t.text :address_complement
      t.text :address_city, null: false
      t.text :address_neighbourhood, null: false
      t.text :address_state, null: false
      t.text :address_zip_code, null: false
      t.text :phone_number, null: false
      t.text :agency, null: false
      t.text :agency_digit, null: false
      t.text :account, null: false
      t.text :account_digit, null: false
      t.text :owner_name, null: false
      t.text :owner_document, null: false

      t.timestamps
    end
  end
end
