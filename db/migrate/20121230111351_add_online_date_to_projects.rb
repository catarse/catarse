class AddOnlineDateToProjects < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :online_date, :datetime
  end
end
