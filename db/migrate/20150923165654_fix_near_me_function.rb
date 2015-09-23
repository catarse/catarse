class FixNearMeFunction < ActiveRecord::Migration
  def change
    execute "
        CREATE OR REPLACE FUNCTION public.near_me(\"1\".projects)
         RETURNS boolean
         LANGUAGE sql
         STABLE SECURITY DEFINER
        AS $function$
          SELECT 
      COALESCE($1.state_acronym, (SELECT pa.address_state FROM project_accounts pa WHERE pa.project_id = $1.project_id)) = (SELECT u.address_state FROM users u WHERE u.id = nullif(current_setting('user_vars.user_id'), '')::int)
        $function$
      "
  end
end
