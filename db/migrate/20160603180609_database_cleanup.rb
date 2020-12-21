class DatabaseCleanup < ActiveRecord::Migration[4.2]
  def change
    if foreign_key_exists?(:users, :channels)
      remove_foreign_key :users, :channels
    end

    execute <<-SQL
      DROP VIEW  subscriber_reports;
      DROP TABLE public.channel_partners;
      DROP TABLE public.channel_post_notifications;
      DROP TABLE public.channel_posts;
      DROP TABLE public.channels_projects;
      DROP TABLE public.channels_subscribers;
      DROP TABLE public.channels;
      DROP TABLE public.near_mes;
      ALTER TABLE public.projects DROP COLUMN short_url;
      ALTER TABLE public.projects DROP COLUMN home_page_comment;
      ALTER TABLE public.projects DROP COLUMN first_contributions;
    SQL
  end
end
