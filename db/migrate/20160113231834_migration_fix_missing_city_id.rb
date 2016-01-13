class MigrationFixMissingCityId < ActiveRecord::Migration
  def up
    execute <<-SQL
-- Old data won't be validated here
ALTER TABLE projects DISABLE TRIGGER sent_validation;

-- Cases where the city is BH
UPDATE projects
SET city_id = 1634
WHERE
    city_id IS NULL
    AND projects.state_order >= 'published'
    AND EXISTS (SELECT true FROM users u WHERE u.id = projects.user_id AND u.address_city = 'BH');

-- Cases where the city is BH
UPDATE projects
SET city_id = 5274
WHERE
    city_id IS NULL
    AND projects.state_order >= 'published';

ALTER TABLE projects ENABLE TRIGGER sent_validation;
    SQL
  end

  def down
  end
end
