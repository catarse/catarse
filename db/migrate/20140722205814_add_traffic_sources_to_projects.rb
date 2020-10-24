class AddTrafficSourcesToProjects < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :traffic_sources, :text, array: true
  end
end
