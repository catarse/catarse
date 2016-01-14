class CopyProjectCityFromOwner < ActiveRecord::Migration
  def up
    execute <<-SQL
    SET statement_timeout TO 0;
    SQL
    execute <<-SQL
UPDATE users SET address_city = 'Curitiba' WHERE lower(address_city) = 'ctba';
UPDATE users SET address_city = 'Belo Horizonte' WHERE lower(address_city) = 'bh';
UPDATE users SET address_city = 'São Paulo' WHERE lower(address_city) = 'sp';
UPDATE users SET address_city = 'Rio de Janeiro' WHERE lower(address_city) = 'rj';

-- Old data won't be validated here
ALTER TABLE projects DISABLE TRIGGER sent_validation;

UPDATE projects
SET city_id = (
    SELECT min(c.id)
    FROM
        cities c
        JOIN states s ON s.id = c.state_id
        JOIN users u ON lower(u.address_state) = lower(s.acronym) AND lower(unaccent(u.address_city)) = lower(unaccent(c.name))
    WHERE u.id = projects.user_id
)
WHERE
    city_id IS NULL
    AND projects.state_order >= 'sent';

ALTER TABLE projects ENABLE TRIGGER sent_validation;
    SQL
  end

  def down
  end
end
