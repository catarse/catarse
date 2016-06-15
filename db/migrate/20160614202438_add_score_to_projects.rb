class AddScoreToProjects < ActiveRecord::Migration
  def up
    execute %{
DROP FUNCTION public.score(pr "1".projects);
CREATE OR REPLACE FUNCTION public.score(pr public.projects) RETURNS numeric
    LANGUAGE sql STABLE
    AS $$
        SELECT score FROM "1".project_scores WHERE project_id = pr.id
    $$;

CREATE OR REPLACE VIEW "1".projects AS
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
    COALESCE(( SELECT
                CASE
                    WHEN ((p.state)::text = 'failed'::text) THEN pt.pledged
                    ELSE pt.paid_pledged
                END AS paid_pledged
           FROM "1".project_totals pt
          WHERE (pt.project_id = p.id)), (0)::numeric) AS pledged,
    COALESCE(( SELECT pt.progress
           FROM "1".project_totals pt
          WHERE (pt.project_id = p.id)), (0)::numeric) AS progress,
    s.acronym AS state_acronym,
    u.name AS owner_name,
    c.name AS city_name,
    p.full_text_index,
    public.is_current_and_online(p.expires_at, (p.state)::text) AS open_for_contributions,
    public.elapsed_time_json(p.*) AS elapsed_time,
    public.score(p.*) as score
   FROM (((((public.projects p
     JOIN public.users u ON ((p.user_id = u.id)))
     JOIN public.cities c ON ((c.id = p.city_id)))
     JOIN public.states s ON ((s.id = c.state_id)))
     JOIN LATERAL public.zone_timestamp(public.online_at(p.*)) od(od) ON (true))
     JOIN LATERAL public.state_order(p.*) so(so) ON (true));

    }
  end

  def down
    execute %{
DROP FUNCTION public.score(pr public.projects);
CREATE OR REPLACE FUNCTION public.score(pr "1".projects) RETURNS numeric
    LANGUAGE sql STABLE
    AS $$
        SELECT score FROM "1".project_scores WHERE project_id = pr.project_id
    $$;

CREATE OR REPLACE VIEW "1".projects AS
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
    COALESCE(( SELECT
                CASE
                    WHEN ((p.state)::text = 'failed'::text) THEN pt.pledged
                    ELSE pt.paid_pledged
                END AS paid_pledged
           FROM "1".project_totals pt
          WHERE (pt.project_id = p.id)), (0)::numeric) AS pledged,
    COALESCE(( SELECT pt.progress
           FROM "1".project_totals pt
          WHERE (pt.project_id = p.id)), (0)::numeric) AS progress,
    s.acronym AS state_acronym,
    u.name AS owner_name,
    c.name AS city_name,
    p.full_text_index,
    public.is_current_and_online(p.expires_at, (p.state)::text) AS open_for_contributions,
    public.elapsed_time_json(p.*) AS elapsed_time
   FROM (((((public.projects p
     JOIN public.users u ON ((p.user_id = u.id)))
     JOIN public.cities c ON ((c.id = p.city_id)))
     JOIN public.states s ON ((s.id = c.state_id)))
     JOIN LATERAL public.zone_timestamp(public.online_at(p.*)) od(od) ON (true))
     JOIN LATERAL public.state_order(p.*) so(so) ON (true));

    }
  end
end
