class AddCuratedPageDescriptionToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :curated_page_description, :text
  end

  def self.down
    remove_column :projects, :curated_page_description
  end
end
