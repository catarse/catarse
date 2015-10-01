class FixIsOwnerOrAdmin < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION public.is_owner_or_admin(integer) RETURNS boolean
          LANGUAGE sql STABLE
          AS $_$
              SELECT
                current_setting('user_vars.user_id') = $1::text
                OR current_user = 'admin';
            $_$;
    SQL
  end

  def down
    execute <<-SQL
      CREATE OR REPLACE FUNCTION public.is_owner_or_admin(integer) RETURNS boolean
          LANGUAGE sql STABLE SECURITY DEFINER
          AS $_$
              SELECT
                current_setting('user_vars.user_id') = $1::text
                OR current_user = 'admin';
            $_$;
    SQL
  end
end
