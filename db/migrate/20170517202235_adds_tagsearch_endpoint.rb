class AddsTagsearchEndpoint < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE OR REPLACE FUNCTION "1".tag_search(query text, count integer)
      RETURNS SETOF "1".public_tags AS
      $BODY$
        SELECT t.*
        FROM "1".public_tags t
        WHERE query IS NOT NULL AND query<>''
        AND (
              t.name % query
              OR
              t.slug % slugify(query)
        )
        ORDER BY GREATEST(similarity(t.name, query), similarity(t.slug, slugify(query))) DESC, name ASC
        LIMIT COALESCE(LEAST(count,50), 10) --10 is default value, 50 is the max value.
      $BODY$
      LANGUAGE sql STABLE;
      GRANT EXECUTE ON FUNCTION "1".tag_search(text,integer) TO anonymous, web_user, admin;
    SQL
  end
  def down
    execute <<-SQL
    DROP FUNCTION "1".tag_search(text,integer);
    SQL
  end
end
