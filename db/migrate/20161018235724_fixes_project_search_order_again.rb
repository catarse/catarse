class FixesProjectSearchOrderAgain < ActiveRecord::Migration
    def up
    execute <<-SQL
      DROP FUNCTION "1".project_search(query text);
      CREATE FUNCTION "1".project_search(query text)
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
            p.score DESC NULLS LAST,
            p.state DESC,
            ts_rank(p.full_text_index, plainto_tsquery('portuguese', unaccent(query))) DESC,
            p.project_id DESC;
     $function$
    SQL
    end

  def down
      %Q{
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
              p.score DESC NULLS LAST,
              p.open_for_contributions DESC,
              p.state_order,
              ts_rank(p.full_text_index, plainto_tsquery('portuguese', unaccent(query))) DESC,
              p.project_id DESC;
       $function$
      }
    end
  end
