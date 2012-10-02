class AddForeignKeyToPaymentDetails < ActiveRecord::Migration
  def up
    add_foreign_key :payment_notifications, :backers
  end

  def down
    remove_foreign_key :payment_notifications, :backers
  end
end
