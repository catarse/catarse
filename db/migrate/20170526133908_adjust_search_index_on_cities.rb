class AdjustSearchIndexOnCities < ActiveRecord::Migration
  def up
    execute %Q{
DROP VIEW "1".cities;
CREATE OR REPLACE VIEW "1"."cities" AS 
 SELECT c.id,
    c.state_id,
    c.name,
    s.name AS state_name,
    s.acronym,
    unaccent(c.name)|| ' ' ||s.acronym AS search_index
   FROM (cities c
     JOIN states s ON ((s.id = c.state_id)));
GRANT SELECT ON "1".cities TO anonymous, web_user, admin;
}
  end

  def down
    execute %Q{
DROP VIEW "1".cities;
CREATE OR REPLACE VIEW "1"."cities" AS 
 SELECT c.id,
    c.state_id,
    c.name,
    s.name AS state_name,
    s.acronym,
    to_tsvector(unaccent(c.name)) AS search_index
   FROM (cities c
     JOIN states s ON ((s.id = c.state_id)));
GRANT SELECT ON "1".cities TO anonymous, web_user, admin;
}
  end
end
