class FixContributionPermission < ActiveRecord::Migration
  def change
    execute <<-SQL
      revoke SELECT on "1".contribution_details from anonymous, web_user;

      create or replace function public.user_has_contributed_to_project(user_id integer, project_id integer) 
      returns boolean
      language sql 
      security definer 
      stable
      as $$
        select true from "1".project_contributions c where c.state = any(public.confirmed_states()) and c.project_id = $2 and c.user_id = $1;
      $$;


      CREATE OR REPLACE FUNCTION public.current_user_has_contributed_to_reward(integer) RETURNS boolean
      LANGUAGE sql STABLE
      AS $_$
          select true from "1".project_contributions c where c.state = any(public.confirmed_states()) and c.reward_id = $1 and c.user_id = current_user_id();
      $_$;
    SQL
  end
end
