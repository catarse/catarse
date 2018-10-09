class AddUploadedImageUrlToUsers < ActiveRecord::Migration
  def change
    add_column :users, :thumbnail_url, :string
  end
end
