class AddCoverIntoUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :cover_image, :text
  end
end
