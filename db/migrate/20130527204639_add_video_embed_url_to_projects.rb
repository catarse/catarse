class AddVideoEmbedUrlToProjects < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :video_embed_url, :string
  end
end
