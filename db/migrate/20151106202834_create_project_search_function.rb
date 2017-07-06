class CreateProjectSearchFunction < ActiveRecord::Migration
  def up
    execute <<-SQL
CREATE INDEX ON projects USING gist (name gist_trgm_ops);

CREATE OR REPLACE FUNCTION public.listing_order(project "1".projects)
RETURNS int
STABLE
LANGUAGE SQL
AS $$
    SELECT
        CASE project.state
            WHEN 'online' THEN 1
            WHEN 'waiting_funds' THEN 2
            WHEN 'successful' THEN 3
            WHEN 'failed' THEN 4
        END;
$$;

CREATE OR REPLACE FUNCTION "1".project_search(query text)
RETURNS SETOF "1".projects
STABLE
LANGUAGE SQL
AS $$
SELECT
    p.*
FROM
    "1".projects p
    JOIN public.projects pr ON pr.id = p.project_id
WHERE
    (
        pr.full_text_index @@ to_tsquery('portuguese', unaccent(query))
        OR
        pr.name % query
    )
    AND pr.state NOT IN ('draft','rejected','deleted','in_analysis','approved')
ORDER BY
    p.listing_order,
    ts_rank(pr.full_text_index, to_tsquery('portuguese', unaccent(query))) DESC,
    pr.id DESC;
$$;

GRANT SELECT ON public.projects TO public;
    SQL
  end

  def down
    execute <<-SQL
DROP FUNCTION "1".project_search(query text) CASCADE;
    SQL
  end
end
