class AddVideoEmbedUrlIntoChannels < ActiveRecord::Migration
  def change
    add_column :channels, :video_embed_url, :text
  end
end
