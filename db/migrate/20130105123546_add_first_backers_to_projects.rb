class AddFirstBackersToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :first_backers, :text
  end
end
