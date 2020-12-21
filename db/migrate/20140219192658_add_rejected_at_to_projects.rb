class AddRejectedAtToProjects < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :rejected_at, :timestamp
  end
end
