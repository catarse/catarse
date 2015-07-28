class AddFullTextIndexToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :full_text_index, :tsvector
  end
end
