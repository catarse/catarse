class AddFollowAllFriendsRpc < ActiveRecord::Migration
  def up
    execute %Q{
alter table public.user_follows
    alter column created_at set default now();

CREATE OR REPLACE FUNCTION public.current_user_id()
 RETURNS integer
 LANGUAGE plpgsql
 stable
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

create or replace function "1".follow_all_friends() RETURNS void
    LANGUAGE SQL
    AS $$
        INSERT INTO public.user_follows (user_id, follow_id)
            (
                SELECT
                    distinct
                        current_user_id() as user_id, 
                        uf.friend_id as follow_id
                FROM public.user_friends uf
                WHERE uf.user_id = current_user_id() 
                    AND NOT EXISTS(
                        SELECT TRUE 
                        FROM public.user_follows ufo 
                        WHERE ufo.user_id = current_user_id()
                            AND ufo.follow_id = uf.friend_id
                    )
            );
    $$;

grant select on public.user_friends to admin, web_user;
grant execute on function "1".follow_all_friends() to admin, web_user;
    }
  end

  def down
    execute %Q{
DROP FUNCTION "1".follow_all_friends();
    }
  end
end
