class CopyProjectCityFromOwner < ActiveRecord::Migration
  def up
    execute <<-SQL
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
    AND projects.state_order >= 'published';

ALTER TABLE projects ENABLE TRIGGER sent_validation;
    SQL
  end

  def down
  end
end
