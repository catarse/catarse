class AddUploadedImageToProjects < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :uploaded_image, :string
  end
end
