class RemoveCuratedProjectDescription < ActiveRecord::Migration
  def self.up
    drop_table :curated_project_descriptions
  end

  def self.down
  end
end
