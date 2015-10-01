class AddFullTextIndexToUsers < ActiveRecord::Migration
  def change
    add_column :users, :full_text_index, :tsvector
  end
end
