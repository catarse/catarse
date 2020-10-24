class AddCoverImageToProjects < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :cover_image, :string
  end
end
