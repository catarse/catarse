class AddAboutHtmlToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :about_html, :text
  end

  def self.down
    remove_column :projects, :about_html
  end
end
