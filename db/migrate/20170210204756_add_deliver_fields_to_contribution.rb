class AddDeliverFieldsToContribution < ActiveRecord::Migration[4.2]
  def change
    add_column :contributions, :delivery_status, :text, default: 'undelivered'
  end
end
