class AddCheckToDeliveryStatus < ActiveRecord::Migration
  def change
    execute "ALTER TABLE contributions ADD CONSTRAINT check_delivery_types CHECK (delivery_status IN('received', 'undelivered', 'error', 'delivered'));"
  end
end
