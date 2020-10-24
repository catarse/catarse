class ChangePaymentsInstallmentsValueNull < ActiveRecord::Migration[4.2]
  def change
    change_column_null :payments, :installment_value, true
  end
end
