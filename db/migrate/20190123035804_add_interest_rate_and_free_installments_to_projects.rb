class AddInterestRateAndFreeInstallmentsToProjects < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :interest_rate, :float
    add_column :projects, :free_installments, :integer, null: false, default: 1
  end
end
