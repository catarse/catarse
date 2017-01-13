class AddManualRefundAtToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :manual_refund_at, :datetime
    add_column :payments, :manual_refund_reason, :text
  end
end
