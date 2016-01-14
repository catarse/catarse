# -*- coding: undecided -*-
class CopyProjectCityFromProjectAccount < ActiveRecord::Migration
  def up
    execute <<-SQL
UPDATE project_accounts SET address_city = 'Curitiba' WHERE lower(address_city) = 'ctba';
UPDATE project_accounts SET address_city = 'Belo Horizonte' WHERE lower(address_city) = 'bh';
UPDATE project_accounts SET address_city = 'São Paulo' WHERE lower(address_city) = 'sp';
UPDATE project_accounts SET address_city = 'Rio de Janeiro' WHERE lower(address_city) = 'rj';

-- Old data won't be validated here
ALTER TABLE projects DISABLE TRIGGER sent_validation;

UPDATE projects
SET city_id = (
    SELECT min(c.id)
    FROM
        cities c
        JOIN states s ON s.id = c.state_id
        JOIN project_accounts pa ON lower(pa.address_state) = lower(s.acronym) AND lower(unaccent(pa.address_city)) = lower(unaccent(c.name))
    WHERE pa.project_id = projects.id
)
WHERE
    city_id IS NULL
    AND EXISTS (
        SELECT true
        FROM project_accounts pa
        WHERE pa.project_id = projects.id
    )
    AND projects.state_order >= 'sent';

ALTER TABLE projects ENABLE TRIGGER sent_validation;
    SQL
  end

  def down
  end
end
