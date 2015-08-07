class CreateContributionsView < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE VIEW "1".contributions AS
    SELECT
      c.id,
      c.project_id,
      c.user_id,
      CASE WHEN anonymous THEN NULL ELSE c.user_id END AS public_user_id,
      c.reward_id,
      c.created_at
    FROM
      public.contributions c;
    GRANT ALL ON "1".contributions TO admin;
    SQL
  end

  def down
    execute <<-SQL
    DROP VIEW "1".contributions;
    SQL
  end
end
