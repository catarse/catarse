class AddCitiesEndpoint < ActiveRecord::Migration
  def change
    execute %Q{
create or replace view "1".cities as
    select
        c.id,
        c.state_id,
        c.name,
        s.name as state_name,
        s.acronym as acronym,
        to_tsvector(unaccent(c.name)) as search_index
    from cities c
        join states s on s.id = c.state_id;

grant select on "1".cities to admin, web_user, anonymous;
}
  end
end
