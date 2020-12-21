class AddVideoEmbedUrlIntoChannels < ActiveRecord::Migration[4.2]
  def change
    add_column :channels, :video_embed_url, :text
  end
end
