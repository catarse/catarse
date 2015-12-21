class NewPostgrestCurrentUserId < ActiveRecord::Migration
  def up
    current_database = execute("SELECT current_database();")[0]["current_database"]
    execute "alter database #{current_database} set postgrest.claims.user_id = '';"
    execute "alter database #{current_database} set postgrest.claims.timezone = 'America/Sao_Paulo';"

    execute <<-SQL
    CREATE OR REPLACE FUNCTION public.current_user_id() RETURNS int
    LANGUAGE sql
    AS $_$
        SELECT nullif(current_setting('postgrest.claims.user_id'), '')::integer;
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
