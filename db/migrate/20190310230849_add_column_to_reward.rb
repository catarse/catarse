class AddColumnToReward < ActiveRecord::Migration
  def change
    add_column :rewards, :uploaded_image, :string
  end
end
