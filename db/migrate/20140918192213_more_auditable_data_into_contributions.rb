class MoreAuditableDataIntoContributions < ActiveRecord::Migration
  def change
    add_column :contributions, :waiting_confirmation_at, :datetime
    add_column :contributions, :canceled_at, :datetime
    add_column :contributions, :refunded_at, :datetime
    add_column :contributions, :requested_refund_at, :datetime
    add_column :contributions, :refunded_and_canceled_at, :datetime
    add_column :contributions, :deleted_at, :datetime
    add_column :contributions, :invalid_payment_at, :datetime
  end
end
