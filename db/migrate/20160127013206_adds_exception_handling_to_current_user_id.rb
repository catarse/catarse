class AddsExceptionHandlingToCurrentUserId < ActiveRecord::Migration
  def up
    execute <<-SQL
CREATE OR REPLACE FUNCTION public.current_user_id()
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN nullif(current_setting('postgrest.claims.user_id'), '')::integer;
EXCEPTION
WHEN others THEN
  SET postgrest.claims.user_id TO '';
  RETURN NULL::integer;
END
    $function$;
    SQL

  end

  def down
    execute <<-SQL
CREATE OR REPLACE FUNCTION public.current_user_id()
 RETURNS integer
 LANGUAGE sql
AS $function$
        SELECT nullif(current_setting('postgrest.claims.user_id'), '')::integer;
    $function$;
    SQL
  end
end
