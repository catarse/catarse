class AddCommentToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :home_page_comment, :text, :default => nil
  end

  def self.down
    remove_column :projects, :home_page_comment
  end
end
