class AddVisibleToCuratedPages < ActiveRecord::Migration
  def self.up
    add_column :curated_pages, :visible, :boolean, :default => false
    CuratedPage.update_all :visible => true
  end

  def self.down
    remove_column :curated_pages, :visible
  end
end
