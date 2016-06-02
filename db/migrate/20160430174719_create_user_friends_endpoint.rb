class CreateUserFriendsEndpoint < ActiveRecord::Migration
  def up
    execute %Q{
CREATE OR REPLACE FUNCTION public.user_following_this_user(uid integer, fid integer) returns boolean
    stable
    language sql
    as $$
    select 
        coalesce(
            (select true from public.user_follows uf where uf.user_id = uid and uf.follow_id = fid), 
            false);    
    $$;

create or replace view "1".user_friends as 
    select
        uf.user_id,
        uf.friend_id,
        public.user_following_this_user(uf.user_id, uf.friend_id) as following,
        f.name,
        public.thumbnail_image(f.*) as avatar,
        ut.total_contributed_projects,
        ut.total_published_projects,
        f.address_city as city,
        f.address_state as state
    from public.user_friends uf
    left join "1".user_totals ut on ut.user_id = uf.friend_id
    join public.users as f on f.id = uf.friend_id
    where public.is_owner_or_admin(uf.user_id) and f.deactivated_at is null;


GRANT SELECT ON "1".user_friends TO admin, web_user;
GRANT SELECT ON public.user_follows TO admin, web_user;
    }
  end

  def down
    execute %Q{
DROP VIEW "1".user_friends;
DROP FUNCTION public.user_following_this_user(uid integer, fid integer);
    }
  end
end
