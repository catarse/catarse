class CreateNearMe < ActiveRecord::Migration
  def change
    create_table :near_mes do |t|
      execute "
      CREATE OR REPLACE FUNCTION public.near_me(\"1\".projects)
       RETURNS boolean
       LANGUAGE sql
       STABLE SECURITY DEFINER
      AS $function$
        SELECT
          pa.address_state = (SELECT u.address_state FROM users u WHERE u.id = nullif(current_setting('user_vars.user_id'), '')::int)
        FROM 
          project_accounts pa
        WHERE
          pa.project_id = $1.project_id;
      $function$
      "
    end
  end
end
