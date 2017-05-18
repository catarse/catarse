class AddsSlugifyFunction < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE OR REPLACE FUNCTION public.slugify(val text)
    RETURNS text AS
    $BODY$
        SELECT regexp_replace(regexp_replace(lower(unaccent(val)),'[^a-z0-9]+','-','g'),'^-|-$','','g');
    $BODY$
    LANGUAGE sql IMMUTABLE;
    GRANT SELECT ON "1".public_tags TO anonymous, web_user, admin;
    SQL
  end
  def down
    execute <<-SQL
    DROP FUNCTION "1".tag_search(text,integer);
    SQL
  end
end
