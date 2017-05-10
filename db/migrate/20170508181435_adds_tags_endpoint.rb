class AddsTagsEndpoint < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE OR REPLACE VIEW "1".public_tags AS
      SELECT
          name,
          slug
      FROM public_tags;
      GRANT SELECT ON "1".public_tags TO anonymous, web_user, admin;
    SQL
  end
  def down
    execute <<-SQL
    DROP VIEW "1".public_tags;
    SQL
  end
end
