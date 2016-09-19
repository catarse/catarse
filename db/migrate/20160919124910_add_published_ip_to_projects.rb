class AddPublishedIpToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :published_ip, :string
  end
end
