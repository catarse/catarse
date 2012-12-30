class AddOnlineDateToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :online_date, :datetime
  end
end
