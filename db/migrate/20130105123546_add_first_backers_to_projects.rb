class AddFirstBackersToProjects < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :first_backers, :text
  end
end
