class CreateContributionDetails < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE OR REPLACE VIEW "1".contribution_details AS
    SELECT
      pa.id,
      c.id AS contribution_id,
      pa.id AS payment_id,
      c.user_id,
      c.project_id,
      c.reward_id,
      p.permalink,
      p.name AS project_name,
      u.name AS user_name,
      u.email,
      u.uploaded_image,
      pa.key,
      pa.value,
      c.anonymous,
      c.payer_email,
      pa.gateway_id,
      pa.state AS payment_state,
      EXISTS(SELECT 1 FROM rewards r WHERE r.id = c.reward_id) AS "has_rewards"
    FROM
      projects p
      JOIN contributions c ON c.project_id = p.id
      JOIN contributions_payments cp ON cp.contribution_id = c.id
      JOIN payments pa ON cp.payment_id = pa.id
      JOIN users u ON c.user_id = u.id;
    SQL
  end

  def down
    execute '
    DROP VIEW "1".contribution_details;
    '
  end
end
