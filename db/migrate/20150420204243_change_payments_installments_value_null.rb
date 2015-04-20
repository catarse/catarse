class ChangePaymentsInstallmentsValueNull < ActiveRecord::Migration
  def change
    change_column_null :payments, :installment_value, true
  end
end
