class DropPaymentLogs < ActiveRecord::Migration[4.2]
  def up
    execute "DROP TABLE IF EXISTS payment_logs"
  end

  def down
  end
end
