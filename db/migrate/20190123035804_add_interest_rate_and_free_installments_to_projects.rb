class AddInterestRateAndFreeInstallmentsToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :interest_rate, :float
    add_column :projects, :free_installments, :integer, null: false, default: 1
  end
end
