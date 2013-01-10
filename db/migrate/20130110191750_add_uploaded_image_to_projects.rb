class AddUploadedImageToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :uploaded_image, :string
  end
end
