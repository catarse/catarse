class FixFinishedProjectsExpired < ActiveRecord::Migration
  def change
    execute <<-SQL
    drop materialized view "1".finished_projects;

    create materialized view "1".finished_projects as
SELECT p.id AS project_id,
    p.category_id,
    p.name AS project_name,
    p.headline,
    p.permalink,
    p.mode,
    p.state::text AS state,
    so.so AS state_order,
    od.od AS online_date,
    p.recommended,
    thumbnail_image(p.*, 'large'::text) AS project_img,
    remaining_time_json(p.*) AS remaining_time,
    public.zone_timestamp(p.expires_at) as expires_at,
    COALESCE(( SELECT pt.pledged
           FROM "1".project_totals pt
          WHERE pt.project_id = p.id), 0::numeric) AS pledged,
    COALESCE(( SELECT pt.progress
           FROM "1".project_totals pt
          WHERE pt.project_id = p.id), 0::numeric) AS progress,
    s.acronym AS state_acronym,
    u.name AS owner_name,
    c.name AS city_name,
    p.full_text_index,
    is_current_and_online(p.expires_at, p.state::text) AS open_for_contributions,
    elapsed_time_json(p.*) AS elapsed_time,
    u.public_name AS owner_public_name
   FROM projects p
     JOIN users u ON p.user_id = u.id
     JOIN cities c ON c.id = p.city_id
     JOIN states s ON s.id = c.state_id
     JOIN LATERAL zone_timestamp(online_at(p.*)) od(od) ON true
     JOIN LATERAL state_order(p.*) so(so) ON true
  WHERE (EXISTS ( SELECT true AS bool
           FROM "1".project_transitions pt
          WHERE (pt.state::text = ANY (ARRAY['successful'::text, 'failed'::text])) AND pt.most_recent AND pt.project_id = p.id));


CREATE UNIQUE INDEX finished_project_uidx ON "1".finished_projects(project_id);

grant select on "1".finished_projects to anonymous, admin, web_user;
  SQL
  end
end
