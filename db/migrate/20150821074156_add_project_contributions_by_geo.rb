class AddProjectContributionsByGeo < ActiveRecord::Migration
  def up
    execute <<-SQL
      create view "1".project_contributions_per_location as
        select
        	addr_agg.project_id,
        	json_agg(
        		json_build_object(
        			'state_acronym', addr_agg.state_acronym,
        			'state_name', addr_agg.state_name,
        			'total_contributions', addr_agg.total_contributions,
        			'total_contributed', addr_agg.total_contributed,
        			'total_on_percentage', addr_agg.total_on_percentage
        		) ORDER BY state_acronym
        	) as source
        from (
        	select
        		p.id as project_id,
        		s.acronym as state_acronym,
        		s.name as state_name,
        		count(c) as total_contributions,
        		sum(c.value) as total_contributed,
        		(
        			(sum(c.value) * 100) / p.goal
        		)::numeric as total_on_percentage
        	from
        		projects p
          join public.contributions c on p.id = c.project_id
          left join public.states s on upper(s.acronym) = upper(c.address_state)
        	where p.is_published and c.was_confirmed
        	group by
        		p.id,
        		s.acronym,
        		s.name
        	order by p.created_at desc
        ) as addr_agg
        group by
        	addr_agg.project_id;

      grant select on "1".project_contributions_per_location to admin;
      grant select on "1".project_contributions_per_location to web_user;
      grant select on "1".project_contributions_per_location to anonymous;
    SQL
  end

  def down
    execute <<-SQL
      drop view "1".project_contributions_per_location;
    SQL
  end
end
