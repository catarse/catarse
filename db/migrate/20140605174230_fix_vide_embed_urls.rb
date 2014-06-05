class FixVideEmbedUrls < ActiveRecord::Migration
  def change
    execute "
    UPDATE projects SET video_embed_url = regexp_replace(video_embed_url, '^(\\w)', '//\\1');
    "
  end
end
