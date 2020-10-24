class AddAdminNotesToBalanceTransfers < ActiveRecord::Migration[4.2]
  def change
    add_column :balance_transfers, :admin_notes, :text
  end
end
