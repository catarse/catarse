class AddFullTextIndexToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :full_text_index, :tsvector
  end
end
