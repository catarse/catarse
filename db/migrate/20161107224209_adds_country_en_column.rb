class AddsCountryEnColumn < ActiveRecord::Migration
  def change
    add_column :countries, :name_en, :string
    execute <<-SQL
    DROP MATERIALIZED VIEW "1".countries;
    CREATE MATERIALIZED VIEW "1".countries AS
      SELECT id, name, name_en FROM countries;
    GRANT SELECT ON "1".countries to admin, web_user, anonymous;
    SQL
  end
end
