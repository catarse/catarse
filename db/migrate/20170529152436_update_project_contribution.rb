class UpdateProjectContribution < ActiveRecord::Migration
  def change
    execute <<-SQL
    CREATE OR REPLACE VIEW "1".project_contributions AS
    SELECT c.anonymous,
    c.project_id,
    c.reward_id::numeric AS reward_id,
    c.id::numeric AS id,
    thumbnail_image(u.*) AS profile_img_thumbnail,
    u.id AS user_id,
    u.name AS user_name,
    c.value,
    pa.state,
    u.email,
    row_to_json(r.*)::jsonb AS reward,
    waiting_payment(pa.*) AS waiting_payment,
    is_owner_or_admin(p.user_id) AS is_owner_or_admin,
    ut.total_contributed_projects,
    zone_timestamp(c.created_at) AS created_at,
    NULL::boolean AS has_another,
    pa.full_text_index,
    c.delivery_status,
    u.created_at as user_created_at,
    ut.total_published_projects,
    pa.payment_method
   FROM contributions c
     JOIN users u ON c.user_id = u.id
     JOIN projects p ON p.id = c.project_id
     JOIN payments pa ON pa.contribution_id = c.id
     LEFT JOIN "1".user_totals ut ON ut.id = u.id
     LEFT JOIN rewards r ON r.id = c.reward_id
  WHERE (was_confirmed(c.*) AND pa.state <> 'pending'::text OR waiting_payment(pa.*)) AND is_owner_or_admin(p.user_id) OR c.user_id = current_user_id();
    SQL
  end
end
