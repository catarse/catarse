class AddElapsedTimeToFinishedProject < ActiveRecord::Migration
  def up
    execute %{
DROP MATERIALIZED VIEW "1".finished_projects;
CREATE MATERIALIZED VIEW "1".finished_projects AS
 SELECT p.id AS project_id,
    p.category_id,
    p.name AS project_name,
    p.headline,
    p.permalink,
    p.mode,
    (p.state)::text AS state,
    so.so AS state_order,
    od.od AS online_date,
    p.recommended,
    public.thumbnail_image(p.*, 'large'::text) AS project_img,
    public.remaining_time_json(p.*) AS remaining_time,
    p.expires_at,
    COALESCE(( SELECT pt.pledged
           FROM project_totals pt
          WHERE (pt.project_id = p.id)), (0)::numeric) AS pledged,
    COALESCE(( SELECT pt.progress
           FROM project_totals pt
          WHERE (pt.project_id = p.id)), (0)::numeric) AS progress,
    s.acronym AS state_acronym,
    u.name AS owner_name,
    c.name AS city_name,
    p.full_text_index,
    public.is_current_and_online(p.expires_at, (p.state)::text) AS open_for_contributions,
    elapsed_time_json(p.*) AS elapsed_time
   FROM (((((public.projects p
     JOIN public.users u ON ((p.user_id = u.id)))
     JOIN public.cities c ON ((c.id = p.city_id)))
     JOIN public.states s ON ((s.id = c.state_id)))
     JOIN LATERAL public.zone_timestamp(public.online_at(p.*)) od(od) ON (true))
     JOIN LATERAL public.state_order(p.*) so(so) ON (true))
  WHERE (EXISTS ( SELECT true AS bool
           FROM "1".project_transitions pt
          WHERE (((pt.state)::text = ANY (ARRAY['successful'::text, 'waiting_funds'::text, 'failed'::text])) AND pt.most_recent AND (pt.project_id = p.id)))) WITH NO DATA;

CREATE UNIQUE INDEX finished_project_uidx ON "1".finished_projects(project_id);

grant select on "1".finished_projects to anonymous, admin, web_user;
    }
  end

  def down
    execute %{
DROP MATERIALIZED VIEW "1".finished_projects;
CREATE MATERIALIZED VIEW "1".finished_projects AS
 SELECT p.id AS project_id,
    p.category_id,
    p.name AS project_name,
    p.headline,
    p.permalink,
    p.mode,
    (p.state)::text AS state,
    so.so AS state_order,
    od.od AS online_date,
    p.recommended,
    public.thumbnail_image(p.*, 'large'::text) AS project_img,
    public.remaining_time_json(p.*) AS remaining_time,
    p.expires_at,
    COALESCE(( SELECT pt.pledged
           FROM project_totals pt
          WHERE (pt.project_id = p.id)), (0)::numeric) AS pledged,
    COALESCE(( SELECT pt.progress
           FROM project_totals pt
          WHERE (pt.project_id = p.id)), (0)::numeric) AS progress,
    s.acronym AS state_acronym,
    u.name AS owner_name,
    c.name AS city_name,
    p.full_text_index,
    public.is_current_and_online(p.expires_at, (p.state)::text) AS open_for_contributions
   FROM (((((public.projects p
     JOIN public.users u ON ((p.user_id = u.id)))
     JOIN public.cities c ON ((c.id = p.city_id)))
     JOIN public.states s ON ((s.id = c.state_id)))
     JOIN LATERAL public.zone_timestamp(public.online_at(p.*)) od(od) ON (true))
     JOIN LATERAL public.state_order(p.*) so(so) ON (true))
  WHERE (EXISTS ( SELECT true AS bool
           FROM "1".project_transitions pt
          WHERE (((pt.state)::text = ANY (ARRAY['successful'::text, 'waiting_funds'::text, 'failed'::text])) AND pt.most_recent AND (pt.project_id = p.id)))) WITH NO DATA;

CREATE UNIQUE INDEX finished_project_uidx ON "1".finished_projects(project_id);
grant select on "1".finished_projects to anonymous, admin, web_user;    
    }
  end
end
