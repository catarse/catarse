class AddSendgridStatisticsToPost < ActiveRecord::Migration
  def change
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

      create or replace view "1".project_posts_details as
        select
          pp.id,
          pp.project_id,
          public.is_owner_or_admin(p.user_id) as is_owner_or_admin,
          pp.exclusive,
          pp.title,
          (
            case
            when not pp.exclusive then pp.comment_html
            when pp.exclusive and (public.is_owner_or_admin(p.user_id) or public.current_user_has_contributed_to_project(p.id)) then pp.comment_html
            else null end
          ) as comment_html,
          pp.created_at,
          delivered_count(pp.*) as delivered_count,
          open_count(pp.*) as open_count
        from project_posts pp
        join projects p on p.id = pp.project_id;
    SQL
  end
end
