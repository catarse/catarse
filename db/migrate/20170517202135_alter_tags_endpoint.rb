class AlterTagsEndpoint < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE OR REPLACE VIEW "1".public_tags AS
      SELECT public_tags.name,
        public_tags.slug,
        count(*) AS uses
      FROM public_tags
      LEFT JOIN taggings ON taggings.public_tag_id = public_tags.id
      GROUP BY public_tags.id;
      GRANT SELECT ON "1".public_tags TO anonymous, web_user, admin;
    SQL
  end
  def down
    execute <<-SQL
    CREATE OR REPLACE VIEW "1".public_tags AS
      SELECT
          name,
          slug
      FROM public_tags;
      GRANT SELECT ON "1".public_tags TO anonymous, web_user, admin;
    SQL
  end
end
