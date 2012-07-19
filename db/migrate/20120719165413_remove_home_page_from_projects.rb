class RemoveHomePageFromProjects < ActiveRecord::Migration
  def up
    remove_column :projects, :home_page
  end

  def down
    add_column :projects, :home_page, :boolean
  end
end
