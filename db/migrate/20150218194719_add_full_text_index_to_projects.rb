class AddFullTextIndexToProjects < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :full_text_index, :tsvector
  end
end
