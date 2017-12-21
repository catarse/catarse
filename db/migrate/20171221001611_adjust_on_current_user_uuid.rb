class AdjustOnCurrentUserUuid < ActiveRecord::Migration
  def up
    execute %Q{
CREATE OR REPLACE FUNCTION public.current_user_uuid()
 RETURNS uuid
 LANGUAGE plpgsql
 STABLE
AS $function$
    BEGIN
      RETURN (select common_id from users where id = current_user_id());
    EXCEPTION
    WHEN others THEN
      RETURN NULL::uuid;
    END
    $function$;
}
  end

  def down
    execute %Q{
CREATE OR REPLACE FUNCTION public.current_user_uuid()
 RETURNS uuid
 LANGUAGE plpgsql
 STABLE
AS $function$
    BEGIN
      RETURN nullif((select common_id from users where id = current_user_id()), '')::uuid;
    EXCEPTION
    WHEN others THEN
      RETURN NULL::uuid;
    END
    $function$;
}
  end
end
