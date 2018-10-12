class TimezonePostsCatarseApi < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE OR REPLACE VIEW "1"."project_posts_details" AS 
    SELECT pp.id,
       pp.project_id,
       is_owner_or_admin(p.user_id) AS is_owner_or_admin,
       pp.title,
           CASE
               WHEN ((pp.recipients)::text = 'public'::text) THEN pp.comment_html
               WHEN (((pp.recipients)::text = 'backers'::text) AND (is_owner_or_admin(p.user_id) OR current_user_has_contributed_to_project(p.id))) THEN pp.comment_html
               WHEN (((pp.recipients)::text = 'reward'::text) AND (is_owner_or_admin(p.user_id) OR current_user_has_contributed_to_reward(pp.reward_id, p.id))) THEN pp.comment_html
               ELSE NULL::text
           END AS comment_html,
       zone_timestamp(pp.created_at) as created_at,
       delivered_count(pp.*) AS delivered_count,
       open_count(pp.*) AS open_count,
       pp.recipients,
       pp.reward_id,
       r.minimum_value
      FROM ((project_posts pp
        LEFT JOIN rewards r ON ((r.id = pp.reward_id)))
        JOIN projects p ON ((p.id = pp.project_id)));
    SQL
  end

  def down
    execute <<-SQL
    CREATE OR REPLACE VIEW "1"."project_posts_details" AS 
    SELECT pp.id,
       pp.project_id,
       is_owner_or_admin(p.user_id) AS is_owner_or_admin,
       pp.title,
           CASE
               WHEN ((pp.recipients)::text = 'public'::text) THEN pp.comment_html
               WHEN (((pp.recipients)::text = 'backers'::text) AND (is_owner_or_admin(p.user_id) OR current_user_has_contributed_to_project(p.id))) THEN pp.comment_html
               WHEN (((pp.recipients)::text = 'reward'::text) AND (is_owner_or_admin(p.user_id) OR current_user_has_contributed_to_reward(pp.reward_id, p.id))) THEN pp.comment_html
               ELSE NULL::text
           END AS comment_html,
       pp.created_at,
       delivered_count(pp.*) AS delivered_count,
       open_count(pp.*) AS open_count,
       pp.recipients,
       pp.reward_id,
       r.minimum_value
      FROM ((project_posts pp
        LEFT JOIN rewards r ON ((r.id = pp.reward_id)))
        JOIN projects p ON ((p.id = pp.project_id)));
    SQL
  end
end
