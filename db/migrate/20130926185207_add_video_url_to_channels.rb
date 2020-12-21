class AddVideoUrlToChannels < ActiveRecord::Migration[4.2]
  def change
    add_column :channels, :video_url, :string
  end
end
