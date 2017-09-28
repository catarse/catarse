class AddFullTextToAdminEndpoint < ActiveRecord::Migration
  def change
    execute <<-SQL
    drop view "1".admin_projects;

    create or replace view "1".admin_projects AS
SELECT p.id AS project_id,
    p.name AS project_name,
    p.state,
    p.expires_at AS project_expires_at,
    p.mode,
    p.updated_at,
    p.full_text_index,
    p.permalink,
    p.goal,
    p.created_at,
    u.name AS owner_name,
    p.user_id,
    u.email,
    p.recommended,
    thumbnail_image(u.*) AS profile_img_thumbnail,
    ( SELECT count(*) AS count
           FROM projects
          WHERE projects.user_id = u.id) AS total_published,
    ( SELECT count(*) AS count
           FROM project_posts
          WHERE project_posts.project_id = p.id) AS posts_count,
    ( SELECT project_posts.created_at
           FROM project_posts
          WHERE project_posts.project_id = p.id
          ORDER BY project_posts.created_at DESC
         LIMIT 1) AS last_post,
    c.name_pt AS category_name,
    p.category_id,
    thumbnail_image(p.*, 'large'::text) AS project_img,
    COALESCE(( SELECT sum(pa.value) / p.goal * 100::numeric
           FROM contributions co
             LEFT JOIN payments pa ON pa.contribution_id = co.id
          WHERE co.project_id = p.id AND
                CASE
                    WHEN (p.state::text <> ALL ( VALUES ('failed'::text), ('rejected'::text))) THEN pa.state = 'paid'::text
                    ELSE pa.state = ANY (ARRAY['paid'::text, 'pending_refund'::text, 'refunded'::text])
                END
          GROUP BY co.project_id), 0::numeric) AS progress,
    COALESCE(( SELECT sum(pa.value) FILTER (WHERE pa.state = 'paid'::text) AS sum
           FROM contributions co
             LEFT JOIN payments pa ON pa.contribution_id = co.id
          WHERE co.project_id = p.id
          GROUP BY co.project_id), 0::numeric) AS pledged,
    od.od AS project_online_date
   FROM projects p
     JOIN LATERAL zone_timestamp(online_at(p.*)) od(od) ON true
     JOIN users u ON u.id = p.user_id
     LEFT JOIN categories c ON c.id = p.category_id
  WHERE p.state::text <> 'deleted'::text;


    grant all on "1".admin_projects to admin;
  SQL
  end
end
