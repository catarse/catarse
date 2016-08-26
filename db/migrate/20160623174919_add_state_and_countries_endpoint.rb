class AddStateAndCountriesEndpoint < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE MATERIALIZED VIEW "1".countries AS
      SELECT * FROM countries;

    CREATE MATERIALIZED VIEW "1".states AS
      SELECT * FROM states;

    GRANT SELECT ON "1".countries, "1".states to admin, web_user, anonymous;
    SQL
  end
  def down
    execute <<-SQL
    DROP VIEW "1".countries, "1".states
    SQL
  end
end
