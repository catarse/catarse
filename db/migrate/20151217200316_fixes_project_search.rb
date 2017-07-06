class FixesProjectSearch < ActiveRecord::Migration
  def change
    execute <<-SQL
CREATE OR REPLACE FUNCTION "1".project_search(query text)
 RETURNS SETOF "1".projects
 LANGUAGE sql
 STABLE
AS $function$
SELECT
    p.*
FROM
    "1".projects p
WHERE
    (
        p.full_text_index @@ plainto_tsquery('portuguese', unaccent(query))
        OR
        p.project_name % query
    )
    AND p.state_order >= 'published'
ORDER BY
    p.open_for_contributions DESC,
    p.state_order,
    ts_rank(p.full_text_index, plainto_tsquery('portuguese', unaccent(query))) DESC,
    p.project_id DESC;
$function$;
    SQL
  end
end
