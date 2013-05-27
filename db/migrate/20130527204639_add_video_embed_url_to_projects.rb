class AddVideoEmbedUrlToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :video_embed_url, :string
  end
end
