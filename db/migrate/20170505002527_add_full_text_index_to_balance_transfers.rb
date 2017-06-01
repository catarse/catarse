class AddFullTextIndexToBalanceTransfers < ActiveRecord::Migration
  def change
    add_column :balance_transfers, :full_text_index, :tsvector
  end
end
