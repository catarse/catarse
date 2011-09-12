class AddPermalinkToCuratedPages < ActiveRecord::Migration
  def self.up
    add_column :curated_pages, :permalink, :string
    add_index :curated_pages, :permalink
  end

  def self.down
    remove_column :curated_pages, :permalink
  end
end
