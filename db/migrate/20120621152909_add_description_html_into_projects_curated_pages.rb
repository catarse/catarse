class AddDescriptionHtmlIntoProjectsCuratedPages < ActiveRecord::Migration
  def self.up
    add_column :projects_curated_pages, :description_html, :text
  end

  def self.down
    remove_column :projects_curated_pages, :description_html
  end
end
