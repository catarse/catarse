class CreateCuratedProjectDescriptions < ActiveRecord::Migration
  def self.up
    create_table :curated_project_descriptions do |t|
      t.integer :project_id
      t.integer :curated_page_id
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :curated_project_descriptions
  end
end
