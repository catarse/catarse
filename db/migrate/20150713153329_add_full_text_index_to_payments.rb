class AddFullTextIndexToPayments < ActiveRecord::Migration[4.2]
  def change
    add_column :payments, :full_text_index, :tsvector
  end
end
