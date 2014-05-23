class AdjustContributionReportToOwnerWithCorrectUserAddress < ActiveRecord::Migration
  def up
    drop_view :contribution_reports_for_project_owners

    execute <<-SQL
      CREATE OR REPLACE VIEW contribution_reports_for_project_owners AS
      SELECT
        b.project_id,
        coalesce(r.id, 0) as reward_id,
        p.user_id as project_owner_id,
        r.description as reward_description,
        b.confirmed_at::date,
        b.value as contribution_value,
        (b.value* (SELECT value::numeric FROM settings WHERE name = 'catarse_fee') ) as service_fee,
        u.email as user_email,
        u.name as user_name,
        b.payer_email as payer_email,
        b.payment_method,
        b.anonymous,
        b.state as state,
        coalesce(u.address_street, b.address_street) as street,
        coalesce(u.address_complement, b.address_complement) as complement,
        coalesce(u.address_number, b.address_number) as address_number,
        coalesce(u.address_neighbourhood, b.address_neighbourhood) as neighbourhood,
        coalesce(u.address_city, b.address_city) as city,
        coalesce(u.address_state, b.address_state) as address_state,
        coalesce(u.address_zip_code, b.address_zip_code) as zip_code
      FROM
        contributions b
      JOIN users u ON u.id = b.user_id
      JOIN projects p ON b.project_id = p.id
      LEFT JOIN rewards r ON r.id = b.reward_id
      WHERE
        b.state IN ('confirmed', 'waiting_confirmation');
    SQL
  end

  def down
    drop_view :contribution_reports_for_project_owners

    execute <<-SQL
      CREATE OR REPLACE VIEW contribution_reports_for_project_owners AS
      SELECT
        b.project_id,
        coalesce(r.id, 0) as reward_id,
        p.user_id as project_owner_id,
        r.description as reward_description,
        b.confirmed_at::date,
        b.value as contribution_value,
        (b.value* (SELECT value::numeric FROM settings WHERE name = 'catarse_fee') ) as service_fee,
        u.email as user_email,
        u.name as user_name,
        b.payer_email as payer_email,
        b.payment_method,
        b.anonymous,
        b.state as state,
        coalesce(b.address_street, u.address_street) as street,
        coalesce(b.address_complement, u.address_complement) as complement,
        coalesce(b.address_number, u.address_number) as address_number,
        coalesce(b.address_neighbourhood, u.address_neighbourhood) as neighbourhood,
        coalesce(b.address_city, u.address_city) as city,
        coalesce(b.address_state, u.address_state) as address_state,
        coalesce(b.address_zip_code, u.address_zip_code) as zip_code
      FROM
        contributions b
      JOIN users u ON u.id = b.user_id
      JOIN projects p ON b.project_id = p.id
      LEFT JOIN rewards r ON r.id = b.reward_id
      WHERE
        b.state IN ('confirmed', 'waiting_confirmation');
    SQL
  end
end
