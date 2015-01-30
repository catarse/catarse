class AddCoverIntoUsers < ActiveRecord::Migration
  def change
    add_column :users, :cover_image, :text
  end
end
