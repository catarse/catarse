class AddImageToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :image, :string
  end
end
