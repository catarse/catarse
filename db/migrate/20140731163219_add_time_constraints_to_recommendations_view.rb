class AddTimeConstraintsToRecommendationsView < ActiveRecord::Migration
  def up
    execute "
    CREATE OR REPLACE VIEW recommendations AS 
    SELECT 
      recommendations.user_id, 
      recommendations.project_id, 
      sum(recommendations.count)::bigint AS count
    FROM (
      SELECT b.user_id, recommendations.id AS project_id, count(DISTINCT recommenders.user_id) AS count
      FROM 
        contributions b 
        JOIN contributions backers_same_projects USING(project_id)
        JOIN contributions recommenders ON recommenders.user_id = backers_same_projects.user_id
        JOIN projects recommendations ON recommendations.id = recommenders.project_id
      WHERE 
        -- state filters on all contribution references
        b.state::text = 'confirmed'::text 
        AND backers_same_projects.state::text = 'confirmed'::text 
        AND recommenders.state::text = 'confirmed'::text

        -- confirmed_at filters based on my recent backs so the cost won't increase too much over time
        AND b.confirmed_at > (current_timestamp - '6 months'::interval) 

        -- recommenders must be recent so the project they recommend is still online
        AND recommenders.confirmed_at > (current_timestamp - '2 months'::interval) 
        AND recommendations.state::text = 'online'::text 

        -- source of recommendations must not be same user that I'm recommending to
        AND b.user_id <> backers_same_projects.user_id 

        -- I don't want to recommend the same project that is generating the recommendation
        AND recommendations.id <> b.project_id 

        -- I want to recommend projects that the user has not contributed to yet
        AND NOT (EXISTS ( SELECT true AS bool FROM contributions b2 WHERE b2.state::text = 'confirmed'::text AND b2.user_id = b.user_id AND b2.project_id = recommendations.id))
      GROUP BY b.user_id, recommendations.id
      UNION 
      SELECT b.user_id, recommendations.id AS project_id, 0 AS count
      FROM 
        contributions b
        JOIN projects p ON b.project_id = p.id
        JOIN projects recommendations ON recommendations.category_id = p.category_id
      WHERE 
        b.state::text = 'confirmed'::text 
        AND recommendations.state::text = 'online'::text
      ) recommendations
    WHERE 
      NOT (EXISTS ( SELECT true AS bool FROM contributions b2 WHERE b2.state::text = 'confirmed'::text AND b2.user_id = recommendations.user_id AND b2.project_id = recommendations.project_id))
    GROUP BY recommendations.user_id, recommendations.project_id
    ORDER BY sum(recommendations.count)::bigint DESC;
    "
  end

  def down
    execute "
    CREATE OR REPLACE VIEW recommendations AS
      SELECT user_id, project_id, sum(count)::bigint as count FROM ((
      SELECT
        b.user_id,
        recommendations.id AS project_id,
        count(distinct recommenders.user_id) AS count
      FROM
        backers b
        JOIN projects p ON p.id = b.project_id
        JOIN backers backers_same_projects ON p.id = backers_same_projects.project_id
        JOIN backers recommenders ON recommenders.user_id = backers_same_projects.user_id
        JOIN projects recommendations ON recommendations.id = recommenders.project_id
      WHERE
        b.state = 'confirmed'
        AND backers_same_projects.state = 'confirmed'
        AND recommenders.state = 'confirmed'
        AND b.user_id <> backers_same_projects.user_id
        AND recommendations.id <> b.project_id
        AND recommendations.state = 'online'
      and NOT EXISTS (
        SELECT true
        FROM backers b2
        WHERE 
          b2.state = 'confirmed'
          AND b2.user_id = b.user_id
          AND b2.project_id = recommendations.id
        )
      GROUP BY 
        b.user_id, recommendations.id
      )
      UNION
      (
      SELECT 
        b.user_id,
        recommendations.id AS project_id,
        0 AS count
      FROM
        backers b
        JOIN projects p ON b.project_id = p.id
        JOIN projects recommendations ON recommendations.category_id = p.category_id
      WHERE
        b.state = 'confirmed'
        AND recommendations.state = 'online'
      ))
      recommendations
      where  
      NOT EXISTS (
        SELECT true
        FROM backers b2
        WHERE 
          b2.state = 'confirmed'
          AND b2.user_id = recommendations.user_id
          AND b2.project_id = recommendations.project_id
        )
        GROUP BY user_id, project_id
        ORDER BY count DESC
    "
  end
end
