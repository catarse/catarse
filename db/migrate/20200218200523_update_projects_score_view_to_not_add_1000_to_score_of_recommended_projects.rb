class UpdateProjectsScoreViewToNotAdd1000ToScoreOfRecommendedProjects < ActiveRecord::Migration
  def up
    execute <<-SQL

    CREATE OR REPLACE VIEW "1"."project_scores" AS 
    SELECT p.id AS project_id,
          CASE
            WHEN (p.mode = 'sub'::text) THEN
              CASE
                  WHEN p.recommended THEN (COALESCE((lt_sub.score)::numeric, (0)::numeric) + (1000)::numeric)
                  ELSE (lt_sub.score)::numeric
              END
            ELSE
              lt_non_sub.score::numeric
          END AS score
      FROM ((projects p
        LEFT JOIN LATERAL ( SELECT count(DISTINCT c.id) AS score
              FROM (contributions c
                LEFT JOIN payments pay ON ((pay.contribution_id = c.id)))
             WHERE (((pay.state = ANY (confirmed_states())) AND (pay.paid_at > (now() - '48:00:00'::interval))) AND (c.project_id = p.id))) lt_non_sub ON (true))
        LEFT JOIN LATERAL ( SELECT count(DISTINCT s.id) AS score
              FROM (common_schema.subscriptions s
                LEFT JOIN common_schema.catalog_payments cp ON ((cp.subscription_id = s.id)))
             WHERE (((cp.status = 'paid'::payment_service.payment_status) AND (cp.created_at > (now() - '48:00:00'::interval))) AND (s.project_id = p.common_id))) lt_sub ON (true))
     WHERE open_for_contributions(p.*);;
   ---

    SQL
  end

  def down
    execute <<-SQL

    CREATE OR REPLACE VIEW "1"."project_scores" AS 
    SELECT p.id AS project_id,
           CASE
               WHEN (p.mode = 'sub'::text) THEN
               CASE
                   WHEN p.recommended THEN (COALESCE((lt_sub.score)::numeric, (0)::numeric) + (1000)::numeric)
                   ELSE (lt_sub.score)::numeric
               END
               ELSE
               CASE
                   WHEN p.recommended THEN (COALESCE((lt_non_sub.score)::numeric, (0)::numeric) + (1000)::numeric)
                   ELSE (lt_non_sub.score)::numeric
               END
           END AS score
      FROM ((projects p
        LEFT JOIN LATERAL ( SELECT count(DISTINCT c.id) AS score
              FROM (contributions c
                LEFT JOIN payments pay ON ((pay.contribution_id = c.id)))
             WHERE (((pay.state = ANY (confirmed_states())) AND (pay.paid_at > (now() - '48:00:00'::interval))) AND (c.project_id = p.id))) lt_non_sub ON (true))
        LEFT JOIN LATERAL ( SELECT count(DISTINCT s.id) AS score
              FROM (common_schema.subscriptions s
                LEFT JOIN common_schema.catalog_payments cp ON ((cp.subscription_id = s.id)))
             WHERE (((cp.status = 'paid'::payment_service.payment_status) AND (cp.created_at > (now() - '48:00:00'::interval))) AND (s.project_id = p.common_id))) lt_sub ON (true))
     WHERE open_for_contributions(p.*);;
   ---

    SQL
  end
end
