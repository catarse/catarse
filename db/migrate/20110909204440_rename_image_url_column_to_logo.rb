class RenameImageUrlColumnToLogo < ActiveRecord::Migration
  def self.up
    rename_column :curated_pages, :image_url, :logo
  end

  def self.down
    rename_column :curated_pages, :logo, :image_url    
  end
end
