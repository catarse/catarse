class AddSlipUrlAndInstallmentsOnContributions < ActiveRecord::Migration
  def change
    add_column :contributions, :slip_url, :text
    add_column :contributions, :installments, :integer, null: false, default: 1
  end
end
