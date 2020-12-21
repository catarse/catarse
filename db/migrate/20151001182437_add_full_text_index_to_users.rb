class AddFullTextIndexToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :full_text_index, :tsvector
  end
end
