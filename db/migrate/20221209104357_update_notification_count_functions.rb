class UpdateNotificationCountFunctions < ActiveRecord::Migration[6.1]
  def up
  def change
    execute <<-SQL
      CREATE OR REPLACE FUNCTION public.delivered_count(project_post project_posts) RETURNS bigint
      LANGUAGE sql AS $$
       select count(distinct notification_user) from sendgrid_events where notification_type = 'ProjectPostNotification' and notification_id IN
       (select ppn.id from project_post_notifications ppn join project_posts pp on pp.id = ppn.project_post_id where pp.id = project_post.id) and event = 'delivered';
      $$;

      CREATE OR REPLACE FUNCTION public.open_count(project_post project_posts) RETURNS bigint
      LANGUAGE sql AS $$
       select count(distinct notification_user) from sendgrid_events where notification_type = 'ProjectPostNotification' and notification_id IN
       (select ppn.id from project_post_notifications ppn join project_posts pp on pp.id = ppn.project_post_id where pp.id = project_post.id) and event = 'open';
      $$;
    SQL
  end

  def down
    execute <<-SQL
      CREATE OR REPLACE FUNCTION public.delivered_count(project_post project_posts) RETURNS bigint
      LANGUAGE sql AS $$
       select count(distinct notification_user) from sendgrid_events where notification_id IN
       (select ppn.id from project_post_notifications ppn join project_posts pp on pp.id = ppn.project_post_id where pp.id = project_post.id) and event = 'delivered';
      $$;

      CREATE OR REPLACE FUNCTION public.open_count(project_post project_posts) RETURNS bigint
      LANGUAGE sql AS $$
       select count(distinct notification_user) from sendgrid_events where notification_id IN
       (select ppn.id from project_post_notifications ppn join project_posts pp on pp.id = ppn.project_post_id where pp.id = project_post.id) and event = 'open';
      $$;
    SQL
  end
end
