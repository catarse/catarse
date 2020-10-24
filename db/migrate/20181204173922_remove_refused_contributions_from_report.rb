class RemoveRefusedContributionsFromReport < ActiveRecord::Migration[4.2]
  def up
    execute <<-SQL

    CREATE OR REPLACE VIEW "1"."project_contributions" AS
    SELECT c.anonymous,
       c.project_id,
       (c.reward_id)::numeric AS reward_id,
       (c.id)::numeric AS id,
       thumbnail_image(u.*) AS profile_img_thumbnail,
       u.id AS user_id,
       u.name AS user_name,
       c.value,
       pa.state,
       case
          when pa.state = 'pending' then null
          else u.email
        end,
       (row_to_json(r.*))::jsonb AS reward,
       waiting_payment(pa.*) AS waiting_payment,
       is_owner_or_admin(p.user_id) AS is_owner_or_admin,
       ut.total_contributed_projects,
       zone_timestamp(c.created_at) AS created_at,
       NULL::boolean AS has_another,
       pa.full_text_index,
       c.delivery_status,
       u.created_at AS user_created_at,
       ut.total_published_projects,
       pa.payment_method,
       c.survey_answered_at,
       s.sent_at,
       s.finished_at,
       COALESCE(
           CASE
               WHEN (c.survey_answered_at IS NOT NULL) THEN 'answered'::text
               WHEN (s.sent_at IS NOT NULL) THEN 'sent'::text
               WHEN (s.sent_at IS NULL) THEN 'not_sent'::text
               ELSE NULL::text
           END, ''::text) AS survey_status,
       u.public_name AS public_user_name
      FROM ((((((contributions c
        JOIN users u ON ((c.user_id = u.id)))
        JOIN projects p ON ((p.id = c.project_id)))
        JOIN payments pa ON (pa.state <> 'refused' AND (pa.contribution_id = c.id)))
        LEFT JOIN "1".user_totals ut ON ((ut.id = u.id)))
        LEFT JOIN rewards r ON ((r.id = c.reward_id)))
        LEFT JOIN surveys s ON ((s.reward_id = c.reward_id)))
     WHERE (is_owner_or_admin(p.user_id) OR (c.user_id = current_user_id()));



     CREATE OR REPLACE VIEW "1"."project_contributions_per_day" AS
     SELECT i.project_id,
        json_agg(json_build_object('paid_at', i.created_at, 'created_at', i.created_at, 'total', i.total, 'total_amount', i.total_amount)) AS source
       FROM ( SELECT c.project_id,
                (p.created_at)::date AS created_at,
                count(c.*) AS total,
                sum(c.value) AS total_amount
               FROM (contributions c
                 JOIN payments p ON ((p.contribution_id = c.id)))
              WHERE p.state <> 'refused' AND ((p.paid_at IS NOT NULL) AND was_confirmed(c.*))
              GROUP BY (p.created_at)::date, c.project_id
              ORDER BY (p.created_at)::date) i
      GROUP BY i.project_id;

      CREATE OR REPLACE VIEW "1"."project_contributions_per_location" AS
      SELECT addr_agg.project_id,
         json_agg(json_build_object('state_acronym', addr_agg.state_acronym, 'state_name', addr_agg.state_name, 'total_contributions', addr_agg.total_contributions, 'total_contributed', addr_agg.total_contributed, 'total_on_percentage', addr_agg.total_on_percentage) ORDER BY addr_agg.state_acronym) AS source
        FROM ( SELECT p.id AS project_id,
                 s.acronym AS state_acronym,
                 s.name AS state_name,
                 count(c.*) AS total_contributions,
                 sum(c.value) AS total_contributed,
                 ((sum(c.value) * (100)::numeric) / COALESCE(pt.pledged, (0)::numeric)) AS total_on_percentage
                FROM ((((projects p

                  JOIN contributions c ON ((p.id = c.project_id)))
                  JOIN payments pa on (pa.state <> 'refused' AND pa.contribution_id = c.id)
                  LEFT JOIN addresses add ON ((add.id = c.address_id)))
                  LEFT JOIN states s ON ((add.state_id = s.id)))
                  LEFT JOIN "1".project_totals pt ON ((pt.project_id = c.project_id)))
               WHERE was_confirmed(c.*)
               GROUP BY p.id, s.acronym, s.name, pt.pledged
               ORDER BY p.created_at DESC) addr_agg
       GROUP BY addr_agg.project_id;

       CREATE OR REPLACE VIEW "1"."project_contributions_per_ref" AS
        SELECT i.project_id,
            json_agg(json_build_object('referral_link', i.referral_link, 'total', i.total, 'total_amount', i.total_amount, 'total_on_percentage', ((i.total_amount / ( SELECT pt.pledged
                  FROM "1".project_totals pt
                  WHERE (pt.project_id = i.project_id))) * (100)::numeric))) AS source
          FROM ( SELECT c.project_id,
                    COALESCE(NULLIF(o.referral, ''::text), o.domain) AS referral_link,
                    count(c.*) AS total,
                    sum(c.value) AS total_amount
                  FROM (contributions c
                    JOIN payments pa ON pa.state <> 'refused' AND pa.contribution_id = c.id
                    LEFT JOIN origins o ON ((o.id = c.origin_id)))
                  WHERE was_confirmed(c.*)
                  GROUP BY COALESCE(NULLIF(o.referral, ''::text), o.domain), c.project_id) i
          GROUP BY i.project_id;

    SQL
  end

  def down
    execute <<-SQL

    CREATE OR REPLACE VIEW "1"."project_contributions" AS
    SELECT c.anonymous,
       c.project_id,
       (c.reward_id)::numeric AS reward_id,
       (c.id)::numeric AS id,
       thumbnail_image(u.*) AS profile_img_thumbnail,
       u.id AS user_id,
       u.name AS user_name,
       c.value,
       pa.state,
       u.email,
       (row_to_json(r.*))::jsonb AS reward,
       waiting_payment(pa.*) AS waiting_payment,
       is_owner_or_admin(p.user_id) AS is_owner_or_admin,
       ut.total_contributed_projects,
       zone_timestamp(c.created_at) AS created_at,
       NULL::boolean AS has_another,
       pa.full_text_index,
       c.delivery_status,
       u.created_at AS user_created_at,
       ut.total_published_projects,
       pa.payment_method,
       c.survey_answered_at,
       s.sent_at,
       s.finished_at,
       COALESCE(
           CASE
               WHEN (c.survey_answered_at IS NOT NULL) THEN 'answered'::text
               WHEN (s.sent_at IS NOT NULL) THEN 'sent'::text
               WHEN (s.sent_at IS NULL) THEN 'not_sent'::text
               ELSE NULL::text
           END, ''::text) AS survey_status,
       u.public_name AS public_user_name
      FROM ((((((contributions c
        JOIN users u ON ((c.user_id = u.id)))
        JOIN projects p ON ((p.id = c.project_id)))
        JOIN payments pa ON ((pa.contribution_id = c.id)))
        LEFT JOIN "1".user_totals ut ON ((ut.id = u.id)))
        LEFT JOIN rewards r ON ((r.id = c.reward_id)))
        LEFT JOIN surveys s ON ((s.reward_id = c.reward_id)))
     WHERE (is_owner_or_admin(p.user_id) OR (c.user_id = current_user_id()));



     CREATE OR REPLACE VIEW "1"."project_contributions_per_day" AS
     SELECT i.project_id,
        json_agg(json_build_object('paid_at', i.created_at, 'created_at', i.created_at, 'total', i.total, 'total_amount', i.total_amount)) AS source
       FROM ( SELECT c.project_id,
                (p.created_at)::date AS created_at,
                count(c.*) AS total,
                sum(c.value) AS total_amount
               FROM (contributions c
                 JOIN payments p ON ((p.contribution_id = c.id)))
              WHERE ((p.paid_at IS NOT NULL) AND was_confirmed(c.*))
              GROUP BY (p.created_at)::date, c.project_id
              ORDER BY (p.created_at)::date) i
      GROUP BY i.project_id;

      CREATE OR REPLACE VIEW "1"."project_contributions_per_location" AS
      SELECT addr_agg.project_id,
         json_agg(json_build_object('state_acronym', addr_agg.state_acronym, 'state_name', addr_agg.state_name, 'total_contributions', addr_agg.total_contributions, 'total_contributed', addr_agg.total_contributed, 'total_on_percentage', addr_agg.total_on_percentage) ORDER BY addr_agg.state_acronym) AS source
        FROM ( SELECT p.id AS project_id,
                 s.acronym AS state_acronym,
                 s.name AS state_name,
                 count(c.*) AS total_contributions,
                 sum(c.value) AS total_contributed,
                 ((sum(c.value) * (100)::numeric) / COALESCE(pt.pledged, (0)::numeric)) AS total_on_percentage
                FROM ((((projects p

                  JOIN contributions c ON ((p.id = c.project_id)))
                  LEFT JOIN addresses add ON ((add.id = c.address_id)))
                  LEFT JOIN states s ON ((add.state_id = s.id)))
                  LEFT JOIN "1".project_totals pt ON ((pt.project_id = c.project_id)))
               WHERE was_confirmed(c.*)
               GROUP BY p.id, s.acronym, s.name, pt.pledged
               ORDER BY p.created_at DESC) addr_agg
       GROUP BY addr_agg.project_id;

       CREATE OR REPLACE VIEW "1"."project_contributions_per_ref" AS
        SELECT i.project_id,
            json_agg(json_build_object('referral_link', i.referral_link, 'total', i.total, 'total_amount', i.total_amount, 'total_on_percentage', ((i.total_amount / ( SELECT pt.pledged
                  FROM "1".project_totals pt
                  WHERE (pt.project_id = i.project_id))) * (100)::numeric))) AS source
          FROM ( SELECT c.project_id,
                    COALESCE(NULLIF(o.referral, ''::text), o.domain) AS referral_link,
                    count(c.*) AS total,
                    sum(c.value) AS total_amount
                  FROM (contributions c
                    LEFT JOIN origins o ON ((o.id = c.origin_id)))
                  WHERE was_confirmed(c.*)
                  GROUP BY COALESCE(NULLIF(o.referral, ''::text), o.domain), c.project_id) i
          GROUP BY i.project_id;

    SQL
  end
end
