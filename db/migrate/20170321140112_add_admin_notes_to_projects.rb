class AddAdminNotesToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :admin_notes, :text
  end
end
