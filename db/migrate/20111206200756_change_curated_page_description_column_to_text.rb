class ChangeCuratedPageDescriptionColumnToText < ActiveRecord::Migration
  def self.up
    change_column(:curated_pages, :description, :text)
  end

  def self.down
    change_column(:curated_pages, :description, :string)
  end
end
