class AddPaymentIdIntoBackers < ActiveRecord::Migration
  def change
    add_column :backers, :payment_id, :string
  end
end
