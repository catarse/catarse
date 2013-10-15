class FixDuplicatedEntriesInRecommendations < ActiveRecord::Migration
  def up
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

  def down
    execute "
    CREATE OR REPLACE VIEW recommendations AS
      SELECT * FROM ((
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
        ORDER BY count DESC
    "
  end
end
