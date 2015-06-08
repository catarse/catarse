class CreateContributorNumbers < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE MATERIALIZED VIEW contributor_numbers AS
      WITH confirmed AS (
          SELECT
            user_id, min(c.id) AS id
          FROM
            "1".contribution_details c
          WHERE
            c.state = ANY(confirmed_states())
          GROUP BY
            user_id
          ORDER BY
            id
      )
      SELECT user_id, row_number() OVER (ORDER BY id) AS number FROM confirmed
    SQL
  end

  def down
    execute "DROP MATERIALIZED VIEW contributor_numbers"
  end
end
