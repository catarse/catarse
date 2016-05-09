class FixesOnCurrentUserIdFunc < ActiveRecord::Migration
  def up
    execute %Q{
CREATE OR REPLACE FUNCTION public.current_user_id()
 RETURNS integer
 LANGUAGE plpgsql
 STABLE
AS $function$
BEGIN
  RETURN nullif(current_setting('postgrest.claims.user_id'), '')::integer;
EXCEPTION
WHEN others THEN
  SET LOCAL postgrest.claims.user_id TO '';
  RETURN NULL::integer;
END
    $function$
;
    }
  end

  def down
    execute %Q{
CREATE OR REPLACE FUNCTION public.current_user_id()
 RETURNS integer
 LANGUAGE plpgsql
 STABLE
AS $function$
BEGIN
  RETURN nullif(current_setting('postgrest.claims.user_id'), '')::integer;
EXCEPTION
WHEN others THEN
  SET postgrest.claims.user_id TO '';
  RETURN NULL::integer;
END
    $function$
;
    }
  end
end
