class AddContributionActivityView < ActiveRecord::Migration
  def up
    execute <<-SQL
CREATE VIEW "1".contribution_activities AS (
    SELECT
        u.id as user_id,
        p.id as project_id,
        public.interval_to_json(age( now()::timestamp, pay.paid_at )) as elapsed_time,
        u.name,
        public.thumbnail_image(u.*) as thumbnail,
        public.thumbnail_image(p.*, 'large'::text) AS project_thumbnail,
        p.name as project_name,
        p.permalink as permalink
    FROM payments pay
    JOIN contributions c on c.id = pay.contribution_id
    JOIN users u on c.user_id = u.id
    JOIN projects p on p.id = c.project_id
    WHERE 
        pay.paid_at BETWEEN current_timestamp - '24 hours'::interval and current_timestamp
        AND NOT c.anonymous
        AND pay.state = 'paid'
        AND u.uploaded_image is not null
        AND p.open_for_contributions
    ORDER BY pay.paid_at DESC
);

GRANT SELECT ON "1".contribution_activities TO web_user, anonymous, admin;
    SQL
  end

  def down
    execute <<-SQL
DROP VIEW "1".contribution_activities;
    SQL
  end
end
