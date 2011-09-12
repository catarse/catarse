class AddSiteIdToCuratedPages < ActiveRecord::Migration
  def self.up
    add_column :curated_pages, :site_id, :integer
  end

  def self.down
    remove_column :curated_pages, :site_id
  end
end
