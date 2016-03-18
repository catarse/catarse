class AddProjectScoreView < ActiveRecord::Migration
  def up
    execute <<-SQL
CREATE VIEW "1".project_scores AS
    SELECT
        p.id as project_id,
        CASE WHEN p.recommended THEN
            COALESCE(lt.score, 0) + 100
        ELSE
            COALESCE(lt.score, 0)
        END as score
    FROM projects p
    LEFT JOIN LATERAL (
        SELECT
            (sum(c.value)/p.goal)*100 as score
        FROM contributions c
        LEFT JOIN payments pay ON pay.contribution_id = c.id
        WHERE pay.state = ANY(confirmed_states())
            AND pay.paid_at > (current_timestamp - '48 hours'::interval)
            AND c.project_id = p.id
    ) lt on true
    WHERE p.open_for_contributions;

GRANT SELECT ON "1".project_scores TO admin, web_user, anonymous;

CREATE OR REPLACE FUNCTION public.score(pr "1".projects) RETURNS numeric
    STABLE LANGUAGE sql
    AS $$
        SELECT score FROM "1".project_scores WHERE project_id = pr.project_id
    $$;
    SQL
  end

  def down
    execute <<-SQL
DROP FUNCTION public.score(pr "1".projects);
DROP VIEW "1".project_scores;
    SQL
  end
end
