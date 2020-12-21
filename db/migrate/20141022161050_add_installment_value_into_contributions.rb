class AddInstallmentValueIntoContributions < ActiveRecord::Migration[4.2]
  def change
    add_column :contributions, :installment_value, :decimal
  end
end
