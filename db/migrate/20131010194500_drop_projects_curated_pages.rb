class DropProjectsCuratedPages < ActiveRecord::Migration
  def change
    drop_table :projects_curated_pages
  end
end
