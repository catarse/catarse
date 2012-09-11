class CreatePaymentNotifications < ActiveRecord::Migration
  def up
    create_table :payment_notifications do |t|
      t.integer :backer_id, null: false
      t.text :status, null: false
      t.text :extra_data
      t.timestamps
    end
  end

  def down
    drop_table :payment_notifications
  end
end
