class DropContributorNumbers < ActiveRecord::Migration
  def up
    execute <<-SQL
    DROP MATERIALIZED VIEW public.contributor_numbers;
   SQL
  end

  def down
    execute <<-SQL
    CREATE MATERIALIZED VIEW public.contributor_numbers AS
     WITH confirmed AS (
         SELECT c.user_id,
            min(c.id) AS id
           FROM "1".contribution_details c
          WHERE c.state = ANY (confirmed_states())
          GROUP BY c.user_id
          ORDER BY min(c.id)
        )
     SELECT confirmed.user_id,
      row_number() OVER (ORDER BY confirmed.id) AS number
     FROM confirmed;
   SQL
  end
end
