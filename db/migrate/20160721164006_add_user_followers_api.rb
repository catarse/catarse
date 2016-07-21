class AddUserFollowersApi < ActiveRecord::Migration
  def change
    execute <<-SQL
        create or replace view "1".user_followers as
            select
                uf.user_id,
                uf.follow_id,
                json_build_object(
                    'name', f.name,
                    'avatar', public.thumbnail_image(f.*),
                    'total_contributed_projects', ut.total_contributed_projects,
                    'total_published_projects', ut.total_published_projects,
                    'city', f.address_city,
                    'state', f.address_state,
                    'following', user_following_this_user(uf.follow_id, uf.user_id)
                ) as source,
                public.zone_timestamp(uf.created_at) as created_at
            from public.user_follows uf
            left join "1".user_totals ut on ut.user_id = uf.user_id
            join public.users as f on f.id = uf.user_id
            where public.is_owner_or_admin(uf.follow_id) and f.deactivated_at is null;

        GRANT SELECT, INSERT, DELETE ON "1".user_followers TO admin, web_user;
    SQL
  end
end
