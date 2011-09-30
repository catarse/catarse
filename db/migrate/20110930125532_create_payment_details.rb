class CreatePaymentDetails < ActiveRecord::Migration
  def self.up
    create_table :payment_details do |t|
      t.references :backer
      t.string :payer_name
      t.string :payer_email
      t.string :city
      t.string :uf
      t.string :payment_method
      t.decimal :net_amount
      t.decimal :total_amount
      t.decimal :service_tax_amount
      t.decimal :backer_amount_tax
      t.string :payment_status
      t.string :service_code
      t.string :institution_of_payment
      t.datetime :payment_date

      t.timestamps
    end
  end

  def self.down
    drop_table :payment_details
  end
end