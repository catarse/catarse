class AddAdminNotesToProjects < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :admin_notes, :text
  end
end
