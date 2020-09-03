class FixCitiesViewProjectEditCitySearch < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE OR REPLACE VIEW "1"."cities" AS 
      SELECT c.id,
        c.state_id,
        c.name,
        s.name AS state_name,
        s.acronym,
        ((unaccent(c.name) || ' ') || s.acronym) AS search_index
      FROM cities c
      JOIN states s ON s.id = c.state_id;
    SQL
  end
  
  def down
    execute <<-SQL
    CREATE OR REPLACE VIEW "1"."cities" AS 
      SELECT c.id,
        c.state_id,
        c.name,
        s.name AS state_name,
        s.acronym,
        -- make search available by city and state name
        ((unaccent(c.name) || ' ') || s.acronym || (unaccent(s.name) || ' ') ) AS search_index
      FROM cities c
      JOIN states s ON s.id = c.state_id;
    SQL
  end
end
