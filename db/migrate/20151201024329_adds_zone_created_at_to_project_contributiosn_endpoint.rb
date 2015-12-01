class AddsZoneCreatedAtToProjectContributiosnEndpoint < ActiveRecord::Migration
 def up
    execute <<-SQL
CREATE OR REPLACE VIEW "1".project_contributions AS
 SELECT c.anonymous,
    c.project_id,
    c.id,
    public.thumbnail_image(u.*) AS profile_img_thumbnail,
    u.id AS user_id,
    u.name AS user_name,
        CASE
            WHEN public.is_owner_or_admin(p.user_id) THEN c.value
            ELSE NULL::numeric
        END AS value,
    public.waiting_payment(pa.*) AS waiting_payment,
    public.is_owner_or_admin(p.user_id) AS is_owner_or_admin,
    ut.total_contributed_projects,
    public.zone_timestamp(c.created_at) AS created_at
   FROM ((((public.contributions c
     JOIN public.users u ON ((c.user_id = u.id)))
     JOIN public.projects p ON ((p.id = c.project_id)))
     JOIN public.payments pa ON ((pa.contribution_id = c.id)))
     LEFT JOIN "1".user_totals ut ON ((ut.user_id = u.id)))
  WHERE ((public.was_confirmed(c.*) OR public.waiting_payment(pa.*)) AND ((NOT c.anonymous) OR public.is_owner_or_admin(p.user_id)));

grant select on "1".project_contributions to admin;
grant select on "1".project_contributions to web_user;
grant select on "1".project_contributions to anonymous;
    SQL
  end

  def down
    execute <<-SQL
CREATE OR REPLACE VIEW "1".project_contributions AS
 SELECT c.anonymous,
    c.project_id,
    c.id,
    public.thumbnail_image(u.*) AS profile_img_thumbnail,
    u.id AS user_id,
    u.name AS user_name,
        CASE
            WHEN public.is_owner_or_admin(p.user_id) THEN c.value
            ELSE NULL::numeric
        END AS value,
    public.waiting_payment(pa.*) AS waiting_payment,
    public.is_owner_or_admin(p.user_id) AS is_owner_or_admin,
    ut.total_contributed_projects,
    c.created_at
   FROM ((((public.contributions c
     JOIN public.users u ON ((c.user_id = u.id)))
     JOIN public.projects p ON ((p.id = c.project_id)))
     JOIN public.payments pa ON ((pa.contribution_id = c.id)))
     LEFT JOIN "1".user_totals ut ON ((ut.user_id = u.id)))
  WHERE ((public.was_confirmed(c.*) OR public.waiting_payment(pa.*)) AND ((NOT c.anonymous) OR public.is_owner_or_admin(p.user_id)));
    SQL
  end
end
