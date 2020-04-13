class AddCodeToCountriesView < ActiveRecord::Migration
  def up
    execute <<-SQL
      DROP MATERIALIZED VIEW "1".countries;

      CREATE MATERIALIZED VIEW "1".countries AS
        SELECT
          countries.id,
          countries.name,
          countries.name_en,
          countries.code
        FROM
          public.countries
        WITH DATA;

      GRANT SELECT ON TABLE "1".countries TO "admin";
      GRANT SELECT ON TABLE "1".countries TO web_user;
      GRANT SELECT ON TABLE "1".countries TO anonymous;
    SQL
  end

  def down
    execute <<-SQL
      DROP MATERIALIZED VIEW "1".countries;

      CREATE MATERIALIZED VIEW "1".countries AS
        SELECT
          countries.id,
          countries.name,
          countries.name_en
        FROM
          public.countries
        WITH DATA;

      GRANT SELECT ON TABLE "1".countries TO "admin";
      GRANT SELECT ON TABLE "1".countries TO web_user;
      GRANT SELECT ON TABLE "1".countries TO anonymous;
    SQL
  end
end
