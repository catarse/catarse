class AddTwitterAndFacebookAndEmailToChannels < ActiveRecord::Migration[4.2]
  def change
    add_column :channels, :twitter, :string
    add_column :channels, :facebook, :string
    add_column :channels, :email, :string
  end
end
