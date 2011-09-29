class ChangePaymentTypeToString < ActiveRecord::Migration
  def self.up
    change_column :payment_logs, :payment_type, :string
    rename_column :payment_logs, :almost, :amount
  end

  def self.down
    remove_column :payment_logs, :payment_type
    add_column :payment_logs, :payment_type, :integer

    rename_column :payment_logs, :amount, :almost
  end
end

