class AdjustProjectTotalsForRejected < ActiveRecord::Migration
  def up
    execute %Q{
CREATE OR REPLACE VIEW "1"."project_totals" AS 
 SELECT c.project_id,
    sum(p.value) AS pledged,
    sum(p.value) FILTER (WHERE (p.state = 'paid'::text)) AS paid_pledged,
    ((sum(p.value) / projects.goal) * (100)::numeric) AS progress,
    sum(p.gateway_fee) AS total_payment_service_fee,
    sum(p.gateway_fee) FILTER (WHERE (p.state = 'paid'::text)) AS paid_total_payment_service_fee,
    count(DISTINCT c.id) AS total_contributions,
    count(DISTINCT c.user_id) AS total_contributors
   FROM ((contributions c
     JOIN projects ON ((c.project_id = projects.id)))
     JOIN payments p ON ((p.contribution_id = c.id)))
  WHERE
        CASE
            WHEN ((projects.state)::text not in('failed', 'rejected')) THEN (p.state = 'paid'::text)
            ELSE (p.state = ANY (confirmed_states()))
        END
  GROUP BY c.project_id, projects.id;
}
  end

  def down
    execute %Q{
CREATE OR REPLACE VIEW "1"."project_totals" AS 
 SELECT c.project_id,
    sum(p.value) AS pledged,
    sum(p.value) FILTER (WHERE (p.state = 'paid'::text)) AS paid_pledged,
    ((sum(p.value) / projects.goal) * (100)::numeric) AS progress,
    sum(p.gateway_fee) AS total_payment_service_fee,
    sum(p.gateway_fee) FILTER (WHERE (p.state = 'paid'::text)) AS paid_total_payment_service_fee,
    count(DISTINCT c.id) AS total_contributions,
    count(DISTINCT c.user_id) AS total_contributors
   FROM ((contributions c
     JOIN projects ON ((c.project_id = projects.id)))
     JOIN payments p ON ((p.contribution_id = c.id)))
  WHERE
        CASE
            WHEN ((projects.state)::text <> 'failed'::text) THEN (p.state = 'paid'::text)
            ELSE (p.state = ANY (confirmed_states()))
        END
  GROUP BY c.project_id, projects.id;
}
  end
end
