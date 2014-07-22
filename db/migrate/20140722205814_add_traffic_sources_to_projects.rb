class AddTrafficSourcesToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :traffic_sources, :text, array: true
  end
end
