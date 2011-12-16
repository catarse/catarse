class AddPaymentMethodAndTokenInBackers < ActiveRecord::Migration
  def self.up
    add_column :backers, :payment_method, :text
    add_column :backers, :payment_token, :text
  end

  def self.down
    remove_column :backers, :payment_method
    remove_column :backers, :payment_token
  end
end