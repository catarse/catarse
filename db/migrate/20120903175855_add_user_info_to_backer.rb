class AddUserInfoToBacker < ActiveRecord::Migration
  def change
    add_column :backers, :payer_name, :text
    add_column :backers, :payer_email, :text
    add_column :backers, :payer_document, :text
    add_column :backers, :address_street, :text
    add_column :backers, :address_number, :text
    add_column :backers, :address_complement, :text
    add_column :backers, :address_neighbourhood, :text
    add_column :backers, :address_zip_code, :text
    add_column :backers, :address_city, :text
    add_column :backers, :address_state, :text
    add_column :backers, :address_phone_number, :text
    add_column :backers, :payment_choice, :text
  end
end
