class AddPaymentServiceFeeToBackers < ActiveRecord::Migration
  def change
    add_column :backers, :payment_service_fee, :numeric
  end
end
