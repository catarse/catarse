class AddCheckToDeliveryStatus < ActiveRecord::Migration[4.2]
  def change
    execute "ALTER TABLE contributions ADD CONSTRAINT check_delivery_types CHECK (delivery_status IN('received', 'undelivered', 'error', 'delivered'));"
  end
end
