class AddDeliverFieldsToContribution < ActiveRecord::Migration
  def change
    add_column :contributions, :delivery_status, :text, default: 'undelivered'
  end
end
