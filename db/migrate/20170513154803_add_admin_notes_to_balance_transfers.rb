class AddAdminNotesToBalanceTransfers < ActiveRecord::Migration
  def change
    add_column :balance_transfers, :admin_notes, :text
  end
end
