class AddPublishedIpToProjects < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :published_ip, :string
  end
end
