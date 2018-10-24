class PostDetailsVisibilityRuleForPostRewards < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION public.current_user_has_contributed_to_one_of_selected_rewards(project_post_id integer, project_id integer)
      RETURNS boolean
      LANGUAGE sql
      STABLE
    AS $function$
          select
            case when (select mode from projects where id = $2) = 'sub' then
              exists(
                select true from common_schema.subscriptions s 
                where s.status::text in('active', 'canceling') 
                    and s.reward_id = (select common_id from rewards where id = (select reward_id from post_rewards where project_post_id = $1 limit 1) limit 1) 
                    and s.user_id = current_user_uuid())
            else
              exists(select true from "1".project_contributions c where c.state = any(public.confirmed_states()) and c.reward_id = (select reward_id from post_rewards where project_post_id = $1 limit 1) and c.user_id = current_user_id())
            end
        $function$
    ;;
    
    
    CREATE OR REPLACE FUNCTION public.minimum_value_to_access_post(project_post_id integer)
      RETURNS numeric
      LANGUAGE plpgsql
      STABLE
    AS $function$
        declare
            _minimum_value numeric;
        begin
        
            select r.minimum_value 
            from post_rewards pr 
            inner join rewards r on r.id = pr.reward_id and pr.project_post_id = $1 
            limit 1
            into _minimum_value;
            
            return _minimum_value;
        end
          $function$;
          
          
          CREATE OR REPLACE FUNCTION public.rewards_that_can_access_post(project_post_id integer)
          RETURNS json
          LANGUAGE plpgsql
          STABLE
         AS $function$
             declare
                 _rewards_json_array json;
             begin
             
                 select array_to_json(ARRAY_AGG(json_build_object(
                                 'common_id', r.common_id, 
                                 'id', r.id, 
                                 'minimum_value', r.minimum_value, 
                                 'title', r.title
                             )))
                 from post_rewards pr 
                 inner join rewards r on 
                     r.id = pr.reward_id and 
                     pr.project_post_id = $1
                 
                 into _rewards_json_array;
                 
                 
                 return _rewards_json_array;
             end
               $function$
         
         


    drop view "1"."project_posts_details";
    CREATE OR REPLACE VIEW "1"."project_posts_details" AS 
     SELECT pp.id,
        pp.project_id,
        is_owner_or_admin(p.user_id) AS is_owner_or_admin,
        pp.title,
            CASE
                WHEN ((pp.recipients)::text = 'public'::text) THEN pp.comment_html
                WHEN (((pp.recipients)::text = 'backers'::text) AND (is_owner_or_admin(p.user_id) OR current_user_has_contributed_to_project(p.id))) THEN pp.comment_html
                WHEN (((pp.recipients)::text = 'rewards'::text) AND (is_owner_or_admin(p.user_id) OR current_user_has_contributed_to_one_of_selected_rewards(pp.id, p.id))) THEN pp.comment_html
                ELSE NULL::text
            END AS comment_html,
        zone_timestamp(pp.created_at) AS created_at,
        delivered_count(pp.*) AS delivered_count,
        open_count(pp.*) AS open_count,
        pp.recipients,
        pp.reward_id,
        minimum_value_to_access_post(pp.id) as minimum_value,
        rewards_that_can_access_post(pp.id) as rewards_that_can_access_post
       FROM project_posts pp
            JOIN projects p ON (p.id = pp.project_id);

      grant select on "1"."project_posts_details" to admin;
      grant select on "1"."project_posts_details" to web_user;
      grant select on "1"."project_posts_details" to anonymous;

    SQL
  end

  def down
    execute <<-SQL
    drop view "1"."project_posts_details";
    CREATE VIEW "1".project_posts_details AS
    SELECT pp.id,
       pp.project_id,
       public.is_owner_or_admin(p.user_id) AS is_owner_or_admin,
       pp.title,
           CASE
               WHEN ((pp.recipients)::text = 'public'::text) THEN pp.comment_html
               WHEN (((pp.recipients)::text = 'backers'::text) AND (public.is_owner_or_admin(p.user_id) OR public.current_user_has_contributed_to_project(p.id))) THEN pp.comment_html
               WHEN (((pp.recipients)::text = 'reward'::text) AND (public.is_owner_or_admin(p.user_id) OR public.current_user_has_contributed_to_reward(pp.reward_id, p.id))) THEN pp.comment_html
               ELSE NULL::text
           END AS comment_html,
       pp.created_at,
       public.delivered_count(pp.*) AS delivered_count,
       public.open_count(pp.*) AS open_count,
       pp.recipients,
       pp.reward_id,
       r.minimum_value
      FROM ((public.project_posts pp
        LEFT JOIN public.rewards r ON ((r.id = pp.reward_id)))
        JOIN public.projects p ON ((p.id = pp.project_id)));

        grant select on "1".project_posts_details to admin;
        grant select on "1".project_posts_details to web_user;
        grant select on "1".project_posts_details to anonymous;
    SQL
  end
end
