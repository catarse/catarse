class AdjustApiToNewOrigin < ActiveRecord::Migration[4.2]
  def up
    execute <<-SQL

      CREATE OR REPLACE FUNCTION origin_utm_simplify(campaign text,source text,medium text,content text,term text)
      RETURNS text AS $$
          select NULLIF(regexp_replace(regexp_replace(COALESCE(campaign,'')||'/'||COALESCE(source,'')||'/'||COALESCE(medium,'')||'/'||COALESCE(content,'')||'/'||COALESCE(term,''),'/+','/','g'),'(^/)|(/$)','','g'),'')
      $$ LANGUAGE SQL
      IMMUTABLE;

      CREATE OR REPLACE VIEW "1"."project_contributions_per_ref" AS
      SELECT i.project_id,
          json_agg(json_build_object('referral_link', i.referral_link, 'total', i.total, 'total_amount', i.total_amount, 'total_on_percentage', ((i.total_amount / ( SELECT pt.pledged
                FROM "1".project_totals pt
                WHERE (pt.project_id = i.project_id))) * (100)::numeric))) AS source
        FROM ( SELECT c.project_id,
                  COALESCE(NULLIF(o.referral, ''::text), origin_utm_simplify(o.campaign,o.source,o.medium,o.content,o.term), o.domain) AS referral_link,
                  count(c.*) AS total,
                  sum(c.value) AS total_amount
                FROM (contributions c
                  JOIN payments pa ON pa.state <> 'refused' AND pa.contribution_id = c.id
                  LEFT JOIN origins o ON ((o.id = c.origin_id)))
                WHERE was_confirmed(c.*)
                GROUP BY COALESCE(NULLIF(o.referral, ''::text), origin_utm_simplify(o.campaign,o.source,o.medium,o.content,o.term), o.domain), c.project_id
        ) i
        GROUP BY i.project_id;

    SQL
  end

  def down
    execute <<-SQL

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

    DROP FUNCTION origin_utm_simplify(campaign text,source text,medium text,content text);
    SQL
  end
end
