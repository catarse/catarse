class UpdateCurrentUserId < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE OR REPLACE FUNCTION public.current_user_id() RETURNS int
    LANGUAGE sql
    AS $_$
        SELECT nullif(current_setting('postgrest.user_id'), '')::integer;
    $_$;
    SQL
  end

  def down
    execute <<-SQL
    CREATE OR REPLACE FUNCTION public.current_user_id() RETURNS int
    LANGUAGE sql
    AS $_$
        SELECT nullif(current_setting('user_vars.user_id'), '')::integer;
    $_$;
    SQL
  end
end
