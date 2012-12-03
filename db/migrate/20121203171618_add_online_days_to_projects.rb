class AddOnlineDaysToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :online_days, :integer, :default => 0
  end
end
