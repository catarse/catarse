class FixProjectPostsPermissions < ActiveRecord::Migration
  def change
    execute  <<-SQL
    CREATE OR REPLACE FUNCTION public.current_user_has_contributed_to_reward(integer) RETURNS boolean
    LANGUAGE sql STABLE
    AS $_$
        select true from "1".contribution_details c where c.state = any(public.confirmed_states()) and c.reward_id = $1 and c.user_id = current_user_id();
      $_$;


      CREATE OR replace view "1".project_posts_details as 
SELECT pp.id,
    pp.project_id,
    is_owner_or_admin(p.user_id) AS is_owner_or_admin,
    pp.exclusive,
    pp.title,
        CASE
            WHEN pp.recipients = 'public' THEN pp.comment_html
            WHEN pp.recipients = 'backers' AND (is_owner_or_admin(p.user_id) OR current_user_has_contributed_to_project(p.id)) THEN pp.comment_html
            WHEN pp.recipients = 'reward' AND (is_owner_or_admin(p.user_id) OR current_user_has_contributed_to_reward(pp.reward_id)) THEN pp.comment_html
            ELSE NULL::text
        END AS comment_html,
    pp.created_at,
    delivered_count(pp.*) AS delivered_count,
    open_count(pp.*) AS open_count,
    pp.recipients,
    pp.reward_id
   FROM project_posts pp
     JOIN projects p ON p.id = pp.project_id;

    SQL
  end
end
