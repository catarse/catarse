class AddWebsiteToChannels < ActiveRecord::Migration[4.2]
  def change
    add_column :channels, :website, :string
  end
end
