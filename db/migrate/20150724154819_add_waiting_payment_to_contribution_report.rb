class AddWaitingPaymentToContributionReport < ActiveRecord::Migration
  def up
    execute <<-SQL
    DROP VIEW "1".contribution_reports_for_project_owners;
    CREATE VIEW "1".contribution_reports_for_project_owners AS
    SELECT 
      b.project_id,
      COALESCE(r.id, 0) AS reward_id,
      p.user_id AS project_owner_id,
      r.description AS reward_description,
      r.deliver_at::date AS deliver_at,
      pa.paid_at::date AS confirmed_at,
      pa.value AS contribution_value,
      pa.value * (( SELECT settings.value::numeric AS value
             FROM settings
            WHERE settings.name = 'catarse_fee'::text)) AS service_fee,
      u.email AS user_email,
      COALESCE(b.payer_document, u.cpf) AS cpf,
      u.name AS user_name,
      b.payer_email,
      pa.gateway,
      b.anonymous,
      pa.state,
      pa.waiting_payment,
      COALESCE(u.address_street, b.address_street) AS street,
      COALESCE(u.address_complement, b.address_complement) AS complement,
      COALESCE(u.address_number, b.address_number) AS address_number,
      COALESCE(u.address_neighbourhood, b.address_neighbourhood) AS neighbourhood,
      COALESCE(u.address_city, b.address_city) AS city,
      COALESCE(u.address_state, b.address_state) AS address_state,
      COALESCE(u.address_zip_code, b.address_zip_code) AS zip_code
     FROM contributions b
       JOIN users u ON u.id = b.user_id
       JOIN projects p ON b.project_id = p.id
       JOIN payments pa ON pa.contribution_id = b.id
       LEFT JOIN rewards r ON r.id = b.reward_id
    WHERE pa.state = ANY (ARRAY['paid'::character varying::text, 'pending'::character varying::text]);
    SQL
  end

  def down
    execute <<-SQL
    DROP VIEW "1".contribution_reports_for_project_owners;
    CREATE VIEW "1".contribution_reports_for_project_owners AS
    SELECT b.project_id,
      COALESCE(r.id, 0) AS reward_id,
      p.user_id AS project_owner_id,
      r.description AS reward_description,
      r.deliver_at::date AS deliver_at,
      pa.paid_at::date AS confirmed_at,
      pa.value AS contribution_value,
      pa.value * (( SELECT settings.value::numeric AS value
             FROM settings
            WHERE settings.name = 'catarse_fee'::text)) AS service_fee,
      u.email AS user_email,
      COALESCE(b.payer_document, u.cpf) AS cpf,
      u.name AS user_name,
      b.payer_email,
      pa.gateway,
      b.anonymous,
      pa.state,
      COALESCE(u.address_street, b.address_street) AS street,
      COALESCE(u.address_complement, b.address_complement) AS complement,
      COALESCE(u.address_number, b.address_number) AS address_number,
      COALESCE(u.address_neighbourhood, b.address_neighbourhood) AS neighbourhood,
      COALESCE(u.address_city, b.address_city) AS city,
      COALESCE(u.address_state, b.address_state) AS address_state,
      COALESCE(u.address_zip_code, b.address_zip_code) AS zip_code
     FROM contributions b
       JOIN users u ON u.id = b.user_id
       JOIN projects p ON b.project_id = p.id
       JOIN payments pa ON pa.contribution_id = b.id
       LEFT JOIN rewards r ON r.id = b.reward_id
    WHERE pa.state = ANY (ARRAY['paid'::character varying::text, 'pending'::character varying::text]);
    SQL
  end
end
