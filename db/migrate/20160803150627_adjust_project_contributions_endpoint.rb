class AdjustProjectContributionsEndpoint < ActiveRecord::Migration
  def up
    %Q{
CREATE OR REPLACE VIEW "1"."project_contributions" AS 
 SELECT 
    c.anonymous,
    c.project_id,
    c.reward_id::numeric,
    (c.id)::numeric AS id,
    thumbnail_image(u.*) AS profile_img_thumbnail,
    u.id AS user_id,
    u.name AS user_name,
    c.value,
    pa.state,
    u.email,
    (row_to_json(r.*))::jsonb as reward,
    waiting_payment(pa.*) AS waiting_payment,
    is_owner_or_admin(p.user_id) AS is_owner_or_admin,
    ut.total_contributed_projects,
    zone_timestamp(c.created_at) AS created_at,
    NULL::boolean AS has_another,
    pa.full_text_index
   FROM (((((public.contributions c
     JOIN public.users u ON ((c.user_id = u.id)))
     JOIN public.projects p ON ((p.id = c.project_id)))
     JOIN public.payments pa ON ((pa.contribution_id = c.id)))
     LEFT JOIN "1".user_totals ut ON ((ut.id = u.id)))
     LEFT JOIN public.rewards r ON ((r.id = c.reward_id)))
  WHERE (((public.was_confirmed(c.*) and pa.state <> 'pending') OR public.waiting_payment(pa.*)) AND public.is_owner_or_admin(p.user_id));
    }
  end

  def down
    %Q{
CREATE OR REPLACE VIEW "1"."project_contributions" AS 
 SELECT c.anonymous,
    c.project_id,
        CASE
            WHEN is_owner_or_admin(p.user_id) THEN (c.reward_id)::numeric
            ELSE NULL::numeric
        END AS reward_id,
    (c.id)::numeric AS id,
    thumbnail_image(u.*) AS profile_img_thumbnail,
    u.id AS user_id,
    u.name AS user_name,
        CASE
            WHEN is_owner_or_admin(p.user_id) THEN c.value
            ELSE NULL::numeric
        END AS value,
        CASE
            WHEN is_owner_or_admin(p.user_id) THEN pa.state
            ELSE NULL::text
        END AS state,
        CASE
            WHEN is_owner_or_admin(p.user_id) THEN u.email
            ELSE NULL::text
        END AS email,
        CASE
            WHEN is_owner_or_admin(p.user_id) THEN (row_to_json(r.*))::jsonb
            ELSE NULL::jsonb
        END AS reward,
    waiting_payment(pa.*) AS waiting_payment,
    is_owner_or_admin(p.user_id) AS is_owner_or_admin,
    ut.total_contributed_projects,
    zone_timestamp(c.created_at) AS created_at,
    NULL::boolean AS has_another,
        CASE
            WHEN is_owner_or_admin(p.user_id) THEN pa.full_text_index
            ELSE NULL::tsvector
        END AS full_text_index
   FROM (((((contributions c
     JOIN users u ON ((c.user_id = u.id)))
     JOIN projects p ON ((p.id = c.project_id)))
     JOIN payments pa ON ((pa.contribution_id = c.id)))
     LEFT JOIN user_totals ut ON ((ut.id = u.id)))
     LEFT JOIN rewards r ON ((r.id = c.reward_id)))
  WHERE ((was_confirmed(c.*) OR waiting_payment(pa.*)) AND ((NOT c.anonymous) OR is_owner_or_admin(p.user_id)));
    }
  end
end
