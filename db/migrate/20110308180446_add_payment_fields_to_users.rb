class AddPaymentFieldsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :full_name, :text
    add_column :users, :address_street, :text
    add_column :users, :address_number, :text
    add_column :users, :address_complement, :text
    add_column :users, :address_neighbourhood, :text
    add_column :users, :address_city, :text
    add_column :users, :address_state, :text
    add_column :users, :address_zip_code, :text
    add_column :users, :phone_number, :text
  end

  def self.down
    remove_column :users, :full_name
    remove_column :users, :address_street
    remove_column :users, :address_number
    remove_column :users, :address_complement
    remove_column :users, :address_neighbourhood
    remove_column :users, :address_city
    remove_column :users, :address_state
    remove_column :users, :address_zip_code
    remove_column :users, :phone_number
  end
end

