class FixProjectSearchForFlex < ActiveRecord::Migration
  def up
    execute <<-SQL
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
    AND pr.state_order >= 'published'
ORDER BY
    p.listing_order,
    ts_rank(pr.full_text_index, to_tsquery('portuguese', unaccent(query))) DESC,
    pr.id DESC;
$$;
    SQL
  end

  def down
    execute <<-SQL
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
    SQL
  end
end
