class CreateProjectsCuratedPages < ActiveRecord::Migration
  def self.up
    create_table :projects_curated_pages do |t|
      t.integer :project_id
      t.integer :curated_page_id
      t.text :description

      t.timestamps
    end
    CuratedPage.all.each do |cp|
      cp.projects.each do |p|
        pcp = ProjectsCuratedPage.new
        pcp.project = p
        pcp.curated_page = cp
        pcp.description = p.curated_page_description
        pcp.save
      end
    end
    remove_column :projects, :curated_page_id
    remove_column :projects, :curated_page_description
  end

  def self.down
    drop_table :projects_curated_pages
  end
end
