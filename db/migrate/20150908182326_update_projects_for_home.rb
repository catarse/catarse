class UpdateProjectsForHome < ActiveRecord::Migration
  def up
     execute <<-SQL
      DROP VIEW "1".projects_for_home;

      CREATE OR REPLACE VIEW "1".projects_for_home AS 
       WITH recommended_projects AS (
           SELECT 'recommended'::text AS origin,
              recommends.id AS project_id,
              recommends.name AS project_name,
              recommends.headline,
              recommends.permalink,
              recommends.state,
              recommends.created_at,
              recommends.remaining_time_json as remaining_time,
              recommends.expires_at,
              img_thumbnail(recommends.*,'large') AS project_img,

              pt.pledged,
              pt.progress,
              s.acronym as state_acronym,
              u.name AS owner_name,
              c.name AS city_name

             FROM (public.projects recommends
              JOIN public.users u ON (recommends.user_id = u.id)
              LEFT JOIN "1".project_totals pt ON (pt.project_id = recommends.id)
              LEFT JOIN public.cities c ON (c.id = recommends.city_id)
              LEFT JOIN public.states s ON (s.id = c.state_id)
              )
            WHERE recommends.recommended AND recommends.state::text = 'online'::text
            ORDER BY random()
           LIMIT 3
          ), recents_projects AS (
           SELECT 'recents'::text AS origin,
              recents.id AS project_id,
              recents.name AS project_name,
              recents.headline,
              recents.permalink,
              recents.state,
              recents.created_at,
              recents.remaining_time_json as remaining_time,
              recents.expires_at,
              img_thumbnail(recents.*,'large') AS project_img,
              pt.pledged,
              s.acronym as state_acronym,
              pt.progress,
              u.name AS owner_name,
              c.name AS city_name

             FROM( public.projects recents
              JOIN public.users u ON (recents.user_id = u.id)
              LEFT JOIN "1".project_totals pt ON (pt.project_id = recents.id)
              LEFT JOIN public.cities c ON (c.id = recents.city_id)
              LEFT JOIN public.states s ON (s.id = c.state_id)
            )
            WHERE recents.state::text = 'online'::text AND (now() - recents.online_date) <= '5 days'::interval AND NOT (recents.id IN ( SELECT recommends.project_id
                     FROM recommended_projects recommends))
            ORDER BY random()
           LIMIT 3
          ), expiring_projects AS (
           SELECT 'expiring'::text AS origin,
              expiring.id AS project_id,
              expiring.name AS project_name,
              expiring.headline,
              expiring.permalink,
              expiring.state,
              expiring.created_at,
              expiring.remaining_time_json as remaining_time,
              expiring.expires_at,
              img_thumbnail(expiring.*,'large') AS project_img,
              pt.pledged,
              s.acronym as state_acronym,
              pt.progress,
              u.name AS owner_name,
              c.name AS city_name
             FROM(public.projects expiring
              JOIN public.users u ON (expiring.user_id = u.id)
              LEFT JOIN "1".project_totals pt ON (pt.project_id = expiring.id)
              LEFT JOIN public.cities c ON (c.id = expiring.city_id)
              LEFT JOIN public.states s ON (s.id = c.state_id)
            )
            WHERE expiring.state::text = 'online'::text AND expiring.expires_at <= (now() + '14 days'::interval) AND NOT (expiring.id IN ( SELECT recommends.project_id
                     FROM recommended_projects recommends
                  UNION
                   SELECT recents.project_id
                     FROM recents_projects recents))
            ORDER BY random()
           LIMIT 3
          )
       SELECT recommended_projects.origin,

          recommended_projects.project_id,
          recommended_projects.project_name,
          recommended_projects.headline,
          recommended_projects.permalink,
          recommended_projects.state_acronym,
          recommended_projects.state,
          recommended_projects.created_at,
          recommended_projects.remaining_time::text,
          recommended_projects.expires_at,
          recommended_projects.project_img,
          recommended_projects.pledged,
          recommended_projects.progress,
          recommended_projects.owner_name ,
          recommended_projects.city_name 
         FROM recommended_projects
      UNION
       SELECT recents_projects.origin,

          recents_projects.project_id,
          recents_projects.project_name,
          recents_projects.headline,
          recents_projects.permalink,
          recents_projects.state_acronym,
          recents_projects.state,
          recents_projects.created_at,
          recents_projects.remaining_time::text,
          recents_projects.expires_at,
          recents_projects.project_img,
          recents_projects.pledged,
          recents_projects.progress,
          recents_projects.owner_name ,
          recents_projects.city_name 

         FROM recents_projects
      UNION
       SELECT expiring_projects.origin,
          expiring_projects.project_id,
          expiring_projects.project_name,
          expiring_projects.headline,
          expiring_projects.permalink,
          expiring_projects.state_acronym,
          expiring_projects.state,
          expiring_projects.created_at,
          expiring_projects.remaining_time::text,
          expiring_projects.expires_at,
          expiring_projects.project_img,
          expiring_projects.pledged,
          expiring_projects.progress,
          expiring_projects.owner_name ,
          expiring_projects.city_name 
         FROM expiring_projects;

      grant select on "1".projects_for_home to anonymous;
      grant select on "1".projects_for_home to web_user;
      grant select on "1".projects_for_home to admin;
    SQL
  end
end
