class AddTwitterAndFacebookAndEmailToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :twitter, :string
    add_column :channels, :facebook, :string
    add_column :channels, :email, :string
  end
end
