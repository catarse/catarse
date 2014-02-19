class AddRejectedAtToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :rejected_at, :timestamp
  end
end
