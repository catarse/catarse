class AddImageToChannels < ActiveRecord::Migration[4.2]
  def change
    add_column :channels, :image, :string
  end
end
