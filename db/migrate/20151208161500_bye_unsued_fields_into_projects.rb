class ByeUnsuedFieldsIntoProjects < ActiveRecord::Migration
  def up
    execute <<-SQL
CREATE OR REPLACE VIEW "1".projects AS
 SELECT p.id AS project_id,
    p.category_id,
    p.name AS project_name,
    p.headline,
    p.permalink,
    public.mode(p.*) AS mode,
    COALESCE(fp.state, (p.state)::text) AS state,
    public.state_order(p.*) AS state_order,
    zone_timestamp(p.online_at) AS online_date,
    p.recommended,
    public.thumbnail_image(p.*, 'large'::text) AS project_img,
    public.remaining_time_json(p.*) AS remaining_time,
    p.expires_at,
    COALESCE(( SELECT pt.pledged
           FROM "1".project_totals pt
          WHERE (pt.project_id = p.id)), (0)::numeric) AS pledged,
    COALESCE(( SELECT pt.progress
           FROM "1".project_totals pt
          WHERE (pt.project_id = p.id)), (0)::numeric) AS progress,
    COALESCE(s.acronym, (pa.address_state)::character varying(255)) AS state_acronym,
    u.name AS owner_name,
    COALESCE(c.name, pa.address_city) AS city_name,
    p.full_text_index,
    public.is_current_and_online(p.expires_at, COALESCE(fp.state, (p.state)::text)) AS open_for_contributions
   FROM (((((public.projects p
     JOIN public.users u ON ((p.user_id = u.id)))
     LEFT JOIN public.flexible_projects fp ON ((fp.project_id = p.id)))
     LEFT JOIN public.project_accounts pa ON ((pa.project_id = p.id)))
     LEFT JOIN public.cities c ON ((c.id = p.city_id)))
     LEFT JOIN public.states s ON ((s.id = c.state_id)));

ALTER TABLE projects
    DROP COLUMN sent_to_analysis_at,
    DROP COLUMN rejected_at,
    DROP COLUMN online_date,
    DROP COLUMN referral_link,
    DROP COLUMN sent_to_draft_at
    SQL
  end

  def down
    execute <<-SQL
set statement_timeout to 0;

CREATE OR REPLACE VIEW "1".projects AS
 SELECT p.id AS project_id,
    p.category_id,
    p.name AS project_name,
    p.headline,
    p.permalink,
    public.mode(p.*) AS mode,
    COALESCE(fp.state, (p.state)::text) AS state,
    public.state_order(p.*) AS state_order,
    p.online_date,
    p.recommended,
    public.thumbnail_image(p.*, 'large'::text) AS project_img,
    public.remaining_time_json(p.*) AS remaining_time,
    p.expires_at,
    COALESCE(( SELECT pt.pledged
           FROM "1".project_totals pt
          WHERE (pt.project_id = p.id)), (0)::numeric) AS pledged,
    COALESCE(( SELECT pt.progress
           FROM "1".project_totals pt
          WHERE (pt.project_id = p.id)), (0)::numeric) AS progress,
    COALESCE(s.acronym, (pa.address_state)::character varying(255)) AS state_acronym,
    u.name AS owner_name,
    COALESCE(c.name, pa.address_city) AS city_name,
    p.full_text_index,
    public.is_current_and_online(p.expires_at, COALESCE(fp.state, (p.state)::text)) AS open_for_contributions
   FROM (((((public.projects p
     JOIN public.users u ON ((p.user_id = u.id)))
     LEFT JOIN public.flexible_projects fp ON ((fp.project_id = p.id)))
     LEFT JOIN public.project_accounts pa ON ((pa.project_id = p.id)))
     LEFT JOIN public.cities c ON ((c.id = p.city_id)))
     LEFT JOIN public.states s ON ((s.id = c.state_id)));

ALTER TABLE projects
    ADD COLUMN referral_link text,
    ADD COLUMN sent_to_analysis_at timestamp without time zone,
    ADD COLUMN rejected_at timestamp without time zone,
    ADD COLUMN online_date timestamp without time zone,
    ADD COLUMN sent_to_draft_at timestamp without time zone;

UPDATE projects p
    SET referral_link = (
        SELECT COALESCE(o.referral, o.domain)
            FROM origins o
            WHERE o.id = p.origin_id ),
    online_date = p.online_at,
    sent_to_analysis_at = p.in_analysis_at,
    rejected_at = (
        SELECT pt.created_at
            FROM "1".project_transitions pt
            WHERE pt.project_id = p.id
                AND pt.state = 'rejected'),
    sent_to_draft_at = p.created_at,
    uploaded_image = (
        CASE WHEN video_thumbnail is not null THEN
            uploaded_image
        ELSE
            COALESCE(uploaded_image, 'missing_image')
        END),
    about_html = COALESCE(about_html, name),
    headline = COALESCE(headline, name);
    SQL
  end
end
