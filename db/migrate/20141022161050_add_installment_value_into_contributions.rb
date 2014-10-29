class AddInstallmentValueIntoContributions < ActiveRecord::Migration
  def change
    add_column :contributions, :installment_value, :decimal
  end
end
