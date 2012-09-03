class AddUploadedImageToUsers < ActiveRecord::Migration
  def change
    add_column :users, :uploaded_image, :text
  end
end
