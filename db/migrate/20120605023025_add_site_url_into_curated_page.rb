class AddSiteUrlIntoCuratedPage < ActiveRecord::Migration
  def self.up
    add_column :curated_pages, :site_url, :string
  end

  def self.down
    remove_column :curated_pages, :site_url
  end
end
