class FixProjectPostDetailsPermissions < ActiveRecord::Migration[4.2]
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
                   inner join post_rewards pr on s.status::text in ('active', 'canceling')
                   inner join rewards rs on s.reward_id = rs.common_id
                       and pr.project_post_id = $1
                       and pr.reward_id = rs.id
                       and s.user_id = current_user_uuid()
                   )
           else
               exists(
                   select true from "1".project_contributions c
                   where c.state = any(public.confirmed_states())
                       and exists(
                           select true from post_rewards
                           where project_post_id = $1
                               and reward_id = c.reward_id
                       )
                       and c.user_id = current_user_id()
                   )
           end
       $function$
    ;;


    GRANT SELECT ON TABLE post_rewards TO admin, web_user, anonymous;

    SQL
  end
end
