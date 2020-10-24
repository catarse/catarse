class AddSlipUrlAndInstallmentsOnContributions < ActiveRecord::Migration[4.2]
  def change
    add_column :contributions, :slip_url, :text
    add_column :contributions, :installments, :integer, null: false, default: 1
  end
end
