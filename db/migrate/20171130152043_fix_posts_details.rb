class FixPostsDetails < ActiveRecord::Migration[4.2]
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
          exists(select true from subscriptions s where status = 'active' and s.project_id = $2 and s.user_id = $1)
        else
          exists(select true from "1".project_contributions c where c.state = any(public.confirmed_states()) and c.project_id = $2 and c.user_id = $1)
        end
      $$;

      CREATE OR REPLACE FUNCTION public.current_user_has_contributed_to_reward(reward_id integer, project_id integer) RETURNS boolean
      LANGUAGE sql STABLE
      AS $_$
      select
        case when (select mode from projects where id = $2) = 'sub' then
          exists(select true from subscriptions s where s.status = 'active' and s.reward_id = $1 and s.user_id = current_user_id())
        else
          exists(select true from "1".project_contributions c where c.state = any(public.confirmed_states()) and c.reward_id = $1 and c.user_id = current_user_id())
        end
      $_$;
      SQL
  end
end
