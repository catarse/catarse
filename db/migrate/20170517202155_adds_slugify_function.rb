class AlterTagsEndpoint < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE OR REPLACE FUNCTION "1".tag_search(query text, count integer)
      RETURNS SETOF "1".public_tags AS
    $BODY$
        SELECT t.*
        FROM "1".public_tags t
        WHERE  query is not null and query<>'' and (
              t.name % query
              OR
              t.slug % query
              OR
              t.slug % regexp_replace(regexp_replace(lower(unaccent(query)),'[^a-z0-9]+','-','g'),'^-|-$','','g')
        )
        ORDER BY uses DESC, name ASC
        LIMIT COALESCE(count, 10)
     $BODY$
  LANGUAGE sql STABLE;
      GRANT SELECT ON "1".public_tags TO anonymous, web_user, admin;
    SQL
  end
  def down
    execute <<-SQL
    DROP FUNCTION "1".tag_search(text,integer);
    SQL
  end
end
