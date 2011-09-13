class AddDescriptionHtmlFieldToCuratedPages < ActiveRecord::Migration
  def self.up
    add_column :curated_pages, :description_html, :text
  end

  def self.down
    remove_column :curated_pages, :description_html
  end
end
