class RenameChannelsProfilesToChannels < ActiveRecord::Migration[4.2]
  def up
    rename_table :channel_profiles, :channels
  end

  def down
    rename_table :channels, :channel_profiles
  end
end
