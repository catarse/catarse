class RefactorRecommendations < ActiveRecord::Migration
  def up
    execute <<-SQL
    DROP VIEW recommendations;
    CREATE OR REPLACE VIEW "1".recommendations AS
      SELECT 
        recommendations.user_id,
        recommendations.project_id,
        sum(recommendations.count)::bigint AS count
      FROM ( 
        SELECT 
          b.user_id,
          recommendations_1.id AS project_id,
          count(DISTINCT recommenders.user_id) AS count
        FROM 
          contributions b
          JOIN contributions backers_same_projects USING (project_id)
          JOIN contributions recommenders ON recommenders.user_id = backers_same_projects.user_id
          JOIN projects recommendations_1 ON recommendations_1.id = recommenders.project_id
        WHERE 
          b.was_confirmed
          AND backers_same_projects.was_confirmed
          AND recommenders.was_confirmed
          AND b.updated_at > (now() - '6 mons'::interval) 
          AND recommenders.updated_at > (now() - '2 mons'::interval) 
          AND recommendations_1.state::text = 'online'::text 
          AND b.user_id <> backers_same_projects.user_id 
          AND recommendations_1.id <> b.project_id AND NOT (EXISTS (
            SELECT true AS bool
            FROM contributions b2
            WHERE b2.was_confirmed AND b2.user_id = b.user_id AND b2.project_id = recommendations_1.id)
          )
          GROUP BY b.user_id, recommendations_1.id
          UNION
          SELECT 
            b.user_id,
            recommendations_1.id AS project_id,
            0 AS count
          FROM 
            contributions b
            JOIN projects p ON b.project_id = p.id
            JOIN projects recommendations_1 ON recommendations_1.category_id = p.category_id
          WHERE b.was_confirmed AND recommendations_1.state::text = 'online'::text
      ) recommendations
      WHERE NOT (EXISTS (
        SELECT true AS bool
        FROM contributions b2
        WHERE b2.was_confirmed AND b2.user_id = recommendations.user_id AND b2.project_id = recommendations.project_id)
      )
      GROUP BY recommendations.user_id, recommendations.project_id
      ORDER BY sum(recommendations.count)::bigint DESC;
      SQL
  end

  def down
    execute <<-SQL
    DROP VIEW recommendations;
    CREATE OR REPLACE VIEW recommendations AS
     SELECT recommendations.user_id,
        recommendations.project_id,
        sum(recommendations.count)::bigint AS count
       FROM ( SELECT b.user_id,
                recommendations_1.id AS project_id,
                count(DISTINCT recommenders.user_id) AS count
               FROM contributions b
                 JOIN contributions backers_same_projects USING (project_id)
                 JOIN contributions recommenders ON recommenders.user_id = backers_same_projects.user_id
                 JOIN projects recommendations_1 ON recommendations_1.id = recommenders.project_id
              WHERE b.state::text = 'confirmed'::text AND backers_same_projects.state::text = 'confirmed'::text AND recommenders.state::text = 'confirmed'::text AND b.confirmed_at > (now() - '6 mons'::interval) AND recommenders.confirmed_at > (now() - '2 mons'::interval) AND recommendations_1.state::text = 'online'::text AND b.user_id <> backers_same_projects.user_id AND recommendations_1.id <> b.project_id AND NOT (EXISTS ( SELECT true AS bool
                       FROM contributions b2
                      WHERE b2.state::text = 'confirmed'::text AND b2.user_id = b.user_id AND b2.project_id = recommendations_1.id))
              GROUP BY b.user_id, recommendations_1.id
            UNION
             SELECT b.user_id,
                recommendations_1.id AS project_id,
                0 AS count
               FROM contributions b
                 JOIN projects p ON b.project_id = p.id
                 JOIN projects recommendations_1 ON recommendations_1.category_id = p.category_id
              WHERE b.state::text = 'confirmed'::text AND recommendations_1.state::text = 'online'::text) recommendations
      WHERE NOT (EXISTS ( SELECT true AS bool
               FROM contributions b2
              WHERE b2.state::text = 'confirmed'::text AND b2.user_id = recommendations.user_id AND b2.project_id = recommendations.project_id))
      GROUP BY recommendations.user_id, recommendations.project_id
      ORDER BY sum(recommendations.count)::bigint DESC;
    SQL
  end
end
