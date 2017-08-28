class FixProjectContributionsPerLocation < ActiveRecord::Migration
  def change
    execute <<-SQL
    create or replace view "1".project_contributions_per_location AS
 SELECT addr_agg.project_id,
    json_agg(json_build_object('state_acronym', addr_agg.state_acronym, 'state_name', addr_agg.state_name, 'total_contributions', addr_agg.total_contributions, 'total_contributed', addr_agg.total_contributed, 'total_on_percentage', addr_agg.total_on_percentage) ORDER BY addr_agg.state_acronym) AS source
   FROM ( SELECT p.id AS project_id,
            s.acronym AS state_acronym,
            s.name AS state_name,
            count(c.*) AS total_contributions,
            sum(c.value) AS total_contributed,
            sum(c.value) * 100::numeric / COALESCE(pt.pledged, 0::numeric) AS total_on_percentage
           FROM projects p
             JOIN contributions c ON p.id = c.project_id
             LEFT JOIN addresses add ON add.id = c.address_id
             LEFT JOIN states s ON add.state_id = s.id
             LEFT JOIN "1".project_totals pt ON pt.project_id = c.project_id
          WHERE was_confirmed(c.*)
          GROUP BY p.id, s.acronym, s.name, pt.pledged
          ORDER BY p.created_at DESC) addr_agg
  GROUP BY addr_agg.project_id;
    SQL
  end
end
