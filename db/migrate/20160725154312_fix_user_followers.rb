class FixUserFollowers < ActiveRecord::Migration
  def change
    execute <<-SQL
    CREATE OR REPLACE VIEW "1".user_followers AS
      SELECT uf.user_id,
      uf.follow_id,
      json_build_object('name', f.name, 'avatar', thumbnail_image(f.*), 'total_contributed_projects', ut.total_contributed_projects, 'total_published_projects', ut.total_published_projects, 'city', f.address_city, 'state', f.address_state, 'following', user_following_this_user(uf.follow_id, uf.user_id)) AS source,
      zone_timestamp(uf.created_at) AS created_at,
      user_following_this_user(uf.follow_id, uf.user_id) as following
     FROM user_follows uf
       LEFT JOIN "1".user_totals ut ON ut.user_id = uf.user_id
       JOIN users f ON f.id = uf.user_id
    WHERE is_owner_or_admin(uf.follow_id) AND f.deactivated_at IS NULL AND uf.follow_id IS NOT NULL;

    SQL
  end
end
