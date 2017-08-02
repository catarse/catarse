class MigrateContributionAddresses < ActiveRecord::Migration
  def change
    execute <<-SQL
alter table addresses add column contribution_id integer;

WITH contribution_addresses AS (
      select * from contributions u where u.address_street is not null 
      ),
rows AS (
    INSERT INTO addresses
        (contribution_id,country_id, state_id, address_street, address_number, address_complement, address_neighbourhood, address_city, address_zip_code, phone_number, created_at, updated_at, address_state)
      select contribution_addresses.id, COALESCE(contribution_addresses.country_id, 36), (select id from states where acronym = contribution_addresses.address_state), address_street, address_number, address_complement, address_neighbourhood, address_city, address_zip_code, address_phone_number, now(), now(), address_state from contribution_addresses
    RETURNING id, contribution_id
)

UPDATE contributions
SET address_id=subquery.id
FROM (SELECT id, contribution_id from rows) AS subquery where contributions.id = subquery.contribution_id ;

alter table addresses drop column contribution_id;
    SQL
  end
end
