class DropProjectsCuratedPages < ActiveRecord::Migration[4.2]
  def change
    drop_table :projects_curated_pages
  end
end
