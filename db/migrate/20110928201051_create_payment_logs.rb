class CreatePaymentLogs < ActiveRecord::Migration
  def self.up
    create_table :payment_logs do |t|
      t.references :backer
      t.integer :status
      t.float :almost
      t.integer :payment_status
      t.integer :moip_id
      t.integer :payment_method
      t.integer :payment_type
      t.string :consumer_email

      t.timestamps
    end
  end

  def self.down
    drop_table :payment_logs
  end
end
