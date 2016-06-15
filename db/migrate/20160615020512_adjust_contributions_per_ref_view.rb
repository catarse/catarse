class AdjustContributionsPerRefView < ActiveRecord::Migration
  def up
    execute %{
CREATE OR REPLACE VIEW "1".project_contributions_per_ref AS
 SELECT i.project_id,
    json_agg(json_build_object('referral_link', i.referral_link, 'total', i.total, 'total_amount', i.total_amount, 'total_on_percentage', ((i.total_amount / ( SELECT pt.pledged
           FROM "1".project_totals pt
          WHERE (pt.project_id = i.project_id))) * (100)::numeric))) AS source
   FROM ( SELECT c.project_id,
            COALESCE(NULLIF(o.referral, ''), o.domain) AS referral_link,
            count(c.*) AS total,
            sum(c.value) AS total_amount
           FROM (public.contributions c
             LEFT JOIN public.origins o ON ((o.id = c.origin_id)))
          WHERE public.was_confirmed(c.*)
          GROUP BY NULLIF(o.referral, ''), o.domain, c.project_id) i
  GROUP BY i.project_id;

    }
  end

  def down
    execute %{
CREATE OR REPLACE VIEW "1".project_contributions_per_ref AS
 SELECT i.project_id,
    json_agg(json_build_object('referral_link', i.referral_link, 'total', i.total, 'total_amount', i.total_amount, 'total_on_percentage', ((i.total_amount / ( SELECT pt.pledged
           FROM "1".project_totals pt
          WHERE (pt.project_id = i.project_id))) * (100)::numeric))) AS source
   FROM ( SELECT c.project_id,
            COALESCE(o.referral, o.domain) AS referral_link,
            count(c.*) AS total,
            sum(c.value) AS total_amount
           FROM (public.contributions c
             LEFT JOIN public.origins o ON ((o.id = c.origin_id)))
          WHERE public.was_confirmed(c.*)
          GROUP BY o.referral, o.domain, c.project_id) i
  GROUP BY i.project_id;

    }
  end
end
