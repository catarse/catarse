class CreateAdminProjectsEndpoint < ActiveRecord::Migration
  def change
    execute <<-SQL
    create or replace view "1".admin_projects AS
    select p.id as project_id,
    p.name as project_name,
    p.state as state,
    p.expires_at as project_expires_at,
    p.mode,
    p.updated_at,
    p.permalink,
    p.goal,
    p.created_at,
    u.name as owner_name,
    p.user_id,
    u.email,
    p.recommended,
    thumbnail_image(u.*) AS profile_img_thumbnail,
    (select count(*) from projects where user_id = u.id) as total_published,
    (select count(*) from project_posts where project_id = p.id) as posts_count,
    (select created_at from project_posts where project_id = p.id order by created_at DESC limit 1) as last_post,
    c.name_pt as category_name,
    p.category_id,
    thumbnail_image(p.*, 'large'::text) AS project_img,
    COALESCE(pledged.paid_pledged, 0::numeric) as pledged,
    COALESCE(pledged.progress, 0::numeric) as progress,
    od.od AS project_online_date
    from projects p
    LEFT join LATERAL( ( SELECT
                CASE
                    WHEN p.state::text = 'failed'::text THEN pt.pledged
                    ELSE pt.paid_pledged
                END AS paid_pledged,
                pt.progress
           FROM "1".project_totals pt
          WHERE pt.project_id = p.id)) as pledged on true
     JOIN LATERAL zone_timestamp(online_at(p.*)) od(od) ON true
     JOIN users u on u.id = p.user_id
     LEFT JOIN categories c on c.id = p.category_id
     where p.state <> 'deleted';

    grant all on "1".admin_projects to admin;
    SQL
  end
end
