class AddFullTextIndexToBalanceTransfers < ActiveRecord::Migration[4.2]
  def change
    add_column :balance_transfers, :full_text_index, :tsvector
  end
end
