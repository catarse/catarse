class AddVisibleToCuratedPages < ActiveRecord::Migration
  def self.up
    add_column :curated_pages, :visible, :boolean, :default => false
    execute("UPDATE curated_pages SET visible = true")
  end

  def self.down
    remove_column :curated_pages, :visible
  end
end
