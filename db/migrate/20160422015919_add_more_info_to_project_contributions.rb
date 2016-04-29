class AddMoreInfoToProjectContributions < ActiveRecord::Migration
  def up
    execute %Q{
DROP VIEW "1"."project_contributions";
CREATE OR REPLACE VIEW "1"."project_contributions" AS
 SELECT
    c.anonymous,
    c.project_id,
    CASE WHEN is_owner_or_admin(p.user_id) THEN c.reward_id ELSE NULL::numeric END AS reward_id,
    CASE WHEN is_owner_or_admin(p.user_id) THEN c.id ELSE NULL::numeric END AS id,
    thumbnail_image(u.*) AS profile_img_thumbnail,
    u.id AS user_id,
    u.name AS user_name,
    CASE WHEN is_owner_or_admin(p.user_id) THEN c.value ELSE NULL::numeric END AS value,
    CASE WHEN is_owner_or_admin(p.user_id) THEN pa.state ELSE NULL::text END AS state,
    CASE WHEN is_owner_or_admin(p.user_id) THEN u.email ELSE NULL::text END AS email,
    CASE WHEN is_owner_or_admin(p.user_id) THEN row_to_json(r.*)::jsonb ELSE NULL::jsonb END AS reward,
    waiting_payment(pa.*) AS waiting_payment,
    is_owner_or_admin(p.user_id) AS is_owner_or_admin,
    ut.total_contributed_projects,
    zone_timestamp(c.created_at) AS created_at,
    CASE WHEN is_owner_or_admin(p.user_id) THEN lt.ex ELSE null::boolean END as has_another,
    CASE WHEN is_owner_or_admin(p.user_id) THEN pa.full_text_index ELSE null::tsvector END full_text_index
   FROM public.contributions c
     JOIN public.users u ON c.user_id = u.id
     JOIN public.projects p ON p.id = c.project_id
     JOIN public.payments pa ON pa.contribution_id = c.id
     LEFT JOIN "1".user_totals ut ON ut.user_id = u.id
     LEFT JOIN public.rewards r ON r.id = c.reward_id
     LEFT JOIN LATERAL (
        select
            true as ex
        from public.contributions c2
        where c2.user_id = u.id and c2.project_id = p.id and c2.id <> c.id and c2.was_confirmed limit 1
     ) as lt on true
  WHERE (was_confirmed(c.*) OR waiting_payment(pa.*)) AND ((NOT c.anonymous) OR is_owner_or_admin(p.user_id));

GRANT SELECT ON "1".project_contributions TO anonymous, web_user, admin;
    }
  end

  def down
    execute %Q{
DROP VIEW "1".project_contributions;
CREATE OR REPLACE VIEW "1".project_contributions AS
 SELECT c.anonymous,
    c.project_id,
    c.id,
    thumbnail_image(u.*) AS profile_img_thumbnail,
    u.id AS user_id,
    u.name AS user_name,
        CASE
            WHEN is_owner_or_admin(p.user_id) THEN c.value
            ELSE NULL::numeric
        END AS value,
    waiting_payment(pa.*) AS waiting_payment,
    is_owner_or_admin(p.user_id) AS is_owner_or_admin,
    ut.total_contributed_projects,
    zone_timestamp(c.created_at) AS created_at
   FROM ((((contributions c
     JOIN public.users u ON ((c.user_id = u.id)))
     JOIN public.projects p ON ((p.id = c.project_id)))
     JOIN public.payments pa ON ((pa.contribution_id = c.id)))
     LEFT JOIN "1".user_totals ut ON ((ut.user_id = u.id)))
  WHERE ((was_confirmed(c.*) OR waiting_payment(pa.*)) AND ((NOT c.anonymous) OR is_owner_or_admin(p.user_id)));

GRANT SELECT ON "1".project_contributions TO anonymous, web_user, admin;
    }
  end
end
