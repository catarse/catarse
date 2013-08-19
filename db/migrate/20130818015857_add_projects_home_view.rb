class AddProjectsHomeView < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE OR REPLACE VIEW projects_for_home AS
        with recommended_projects as (
          select 'recommended'::text as origin, recommends.* from projects recommends
          where recommends.recommended and recommends.state = 'online' order by random() limit 3
        ),
        recents_projects as (
          select 'recents'::text as origin, recents.* from projects recents
          where recents.state = 'online'
          and ((current_timestamp - recents.online_date) <= '5 days'::interval)
          and recents.id not in(
            select recommends.id from recommended_projects recommends
          )
          order by random() limit 3
        ),
        expiring_projects as (
          select 'expiring'::text as origin, expiring.* from projects expiring
          where expiring.state = 'online'
          and ((expiring.expires_at) <= ((current_timestamp) + interval '2 weeks'))
          and expiring.id not in(
            (select recommends.id from recommended_projects recommends)
            union (select recents.id from recents_projects recents)
          )
          order by random() limit 3
        )

        (select * from recommended_projects) union (select * from recents_projects) union (select * from expiring_projects)

    SQL
  end

  def down
    execute "DROP VIEW projects_for_home"
  end
end
