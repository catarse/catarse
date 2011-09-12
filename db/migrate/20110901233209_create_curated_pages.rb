class CreateCuratedPages < ActiveRecord::Migration
  def self.up
    create_table :curated_pages do |t|
      t.string :name
      t.string :description
      t.string :analytics_id
      t.string :image_url
      t.string :video_url

      t.timestamps
    end
    
    add_column :projects, :curated_page_id, :integer
  end

  def self.down
    drop_table :curated_pages
    remove_column :projects, :curated_page_id
  end
end
