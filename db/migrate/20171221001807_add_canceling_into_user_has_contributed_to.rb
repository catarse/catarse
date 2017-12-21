class AddCancelingIntoUserHasContributedTo < ActiveRecord::Migration
  def up
    execute %Q{
CREATE OR REPLACE FUNCTION public.user_has_contributed_to_project(user_id integer, project_id integer)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
AS $function$
      select
        case when (select mode from projects where id = $2) = 'sub' then
          exists(select true from common_schema.subscriptions s where status in('active', 'canceling') and s.project_id = (select common_id from projects where id = $2 limit 1) and s.user_id = current_user_uuid())
        else
          exists(select true from "1".project_contributions c where c.state = any(public.confirmed_states()) and c.project_id = $2 and c.user_id = $1)
        end
      $function$
;
CREATE OR REPLACE FUNCTION public.current_user_has_contributed_to_reward(reward_id integer, project_id integer)
 RETURNS boolean
 LANGUAGE sql
 STABLE
AS $function$
      select
        case when (select mode from projects where id = $2) = 'sub' then
          exists(select true from common_schema.subscriptions s where s.status in('active', 'canceling') and s.reward_id = (select common_id from rewards where id = $1 limit 1) and s.user_id = current_user_uuid())
        else
          exists(select true from "1".project_contributions c where c.state = any(public.confirmed_states()) and c.reward_id = $1 and c.user_id = current_user_id())
        end
      $function$
;
}
  end

  def down
    execute %Q{
CREATE OR REPLACE FUNCTION public.user_has_contributed_to_project(user_id integer, project_id integer)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
AS $function$
      select
        case when (select mode from projects where id = $2) = 'sub' then
          exists(select true from common_schema.subscriptions s where status = 'active' and s.project_id = (select common_id from projects where id = $2 limit 1) and s.user_id = current_user_uuid())
        else
          exists(select true from "1".project_contributions c where c.state = any(public.confirmed_states()) and c.project_id = $2 and c.user_id = $1)
        end
      $function$
;
CREATE OR REPLACE FUNCTION public.current_user_has_contributed_to_reward(reward_id integer, project_id integer)
 RETURNS boolean
 LANGUAGE sql
 STABLE
AS $function$
      select
        case when (select mode from projects where id = $2) = 'sub' then
          exists(select true from common_schema.subscriptions s where s.status = 'active' and s.reward_id = (select common_id from rewards where id = $1 limit 1) and s.user_id = current_user_uuid())
        else
          exists(select true from "1".project_contributions c where c.state = any(public.confirmed_states()) and c.reward_id = $1 and c.user_id = current_user_id())
        end
      $function$
;
}
  end
end
