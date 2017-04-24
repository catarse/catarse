class AddsPublicNameToUserFriends < ActiveRecord::Migration
  def change
    execute <<-SQL
    CREATE OR REPLACE VIEW "1".user_friends AS
      SELECT
          uf.user_id,
          uf.friend_id,
          public.user_following_this_user(uf.user_id, uf.friend_id) AS following,
          f.name,
          public.thumbnail_image(f.*) AS avatar,
          ut.total_contributed_projects,
          ut.total_published_projects,
          f.address_city AS city,
          f.address_state AS state,
          f.public_name
      FROM public.user_friends uf
      LEFT JOIN "1".user_totals ut ON ut.user_id = uf.friend_id
      JOIN public.users AS f ON f.id = uf.friend_id
      WHERE public.is_owner_or_admin(uf.user_id) AND f.deactivated_at IS NULL;

      CREATE OR REPLACE VIEW "1".user_followers AS
        SELECT uf.user_id,
        uf.follow_id,
        json_build_object('name', f.name, 'pulic_name', f.public_name, 'avatar', thumbnail_image(f.*), 'total_contributed_projects', ut.total_contributed_projects, 'total_published_projects', ut.total_published_projects, 'city', f.address_city, 'state', f.address_state, 'following', user_following_this_user(uf.follow_id, uf.user_id)) AS source,
        zone_timestamp(uf.created_at) AS created_at,
        user_following_this_user(uf.follow_id, uf.user_id) AS following
       FROM user_follows uf
         LEFT JOIN "1".user_totals ut ON ut.user_id = uf.user_id
         JOIN users f ON f.id = uf.user_id
      WHERE is_owner_or_admin(uf.follow_id) AND f.deactivated_at IS NULL AND uf.follow_id IS NOT NULL;

      CREATE OR REPLACE VIEW "1".creator_suggestions AS
      SELECT
          u.id,
          u.id AS user_id,
          thumbnail_image(u.*) AS avatar,
          u.name AS name,
          u.address_city AS city,
          u.address_state AS state,
          ut.total_contributed_projects AS total_contributed_projects,
          ut.total_published_projects AS total_published_projects,
          public.zone_timestamp(u.created_at) AS created_at,
          public.user_following_this_user(public.current_user_id(), u.id) AS following,
          u.public_name
      FROM public.contributions c
      JOIN public.projects p ON p.id = c.project_id
      JOIN public.users u ON u.id = p.user_id
      JOIN "1".user_totals ut ON ut.user_id = u.id
      WHERE c.was_confirmed AND u.id <> public.current_user_id() AND c.user_id = public.current_user_id() AND u.deactivated_at IS NULL
      GROUP by u.id, ut.total_contributed_projects, ut.total_published_projects;
  SQL
  end
end
