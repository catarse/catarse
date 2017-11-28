class UpdatePostDetails < ActiveRecord::Migration
  def change
    execute <<-SQL
      CREATE OR REPLACE FUNCTION public.user_has_contributed_to_project(user_id integer, project_id integer) 
      returns boolean
      language sql 
      security definer 
      stable
      as $$
      select
        case when (select mode from projects where id = $2) = 'sub' then
          (select true from subscriptions s where status = 'active' and s.project_id = $2 and s.user_id = $1)
        else
          (select true from "1".project_contributions c where c.state = any(public.confirmed_states()) and c.project_id = $2 and c.user_id = $1)
        end
      $$;

      CREATE OR REPLACE FUNCTION public.current_user_has_contributed_to_reward(reward_id integer, project_id integer) RETURNS boolean
      LANGUAGE sql STABLE
      AS $_$
      select
        case when (select mode from projects where id = $2) = 'sub' then
          (select true from subscriptions s where s.status = 'active' and s.reward_id = $1 and s.user_id = current_user_id())
        else
          (select true from "1".project_contributions c where c.state = any(public.confirmed_states()) and c.reward_id = $1 and c.user_id = current_user_id())
        end
      $_$;

      grant SELECT on subscriptions to admin, web_user, anonymous;

      CREATE OR REPLACE VIEW "1".project_posts_details as
      SELECT pp.id,
      pp.project_id,
      is_owner_or_admin(p.user_id) AS is_owner_or_admin,
      pp.title,
          CASE
              WHEN pp.recipients::text = 'public'::text THEN pp.comment_html
              WHEN pp.recipients::text = 'backers'::text AND (is_owner_or_admin(p.user_id) OR current_user_has_contributed_to_project(p.id)) THEN pp.comment_html
              WHEN pp.recipients::text = 'reward'::text AND (is_owner_or_admin(p.user_id) OR current_user_has_contributed_to_reward(pp.reward_id, p.id)) THEN pp.comment_html
              ELSE NULL::text
          END AS comment_html,
      pp.created_at,
      delivered_count(pp.*) AS delivered_count,
      open_count(pp.*) AS open_count,
      pp.recipients,
      pp.reward_id,
      r.minimum_value
     FROM project_posts pp
       LEFT JOIN rewards r ON r.id = pp.reward_id
       JOIN projects p ON p.id = pp.project_id;

    SQL
  end
end
