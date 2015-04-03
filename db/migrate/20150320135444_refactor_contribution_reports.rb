class RefactorContributionReports < ActiveRecord::Migration
  def up
    execute <<-SQL
    DROP VIEW contribution_reports;
    CREATE OR REPLACE VIEW "1".contribution_reports AS
      SELECT 
        b.project_id,
        u.name,
        replace(b.value::text, '.'::text, ','::text) AS value,
        replace(r.minimum_value::text, '.'::text, ','::text) AS minimum_value,
        r.description,
        p.gateway,
        p.gateway_data->'acquirer_name' AS acquirer_name,
        p.gateway_data->'tid' AS acquirer_tid,
        p.payment_method,
        replace(p.gateway_fee::text, '.'::text, ','::text) AS payment_service_fee,
        p.key,
        b.created_at::date AS created_at,
        p.paid_at::date AS confirmed_at,
        u.email,
        b.payer_email,
        b.payer_name,
        COALESCE(b.payer_document, u.cpf) AS cpf,
        u.address_street,
        u.address_complement,
        u.address_number,
        u.address_neighbourhood,
        u.address_city,
        u.address_state,
        u.address_zip_code,
        p.state
      FROM contributions b
        JOIN users u ON u.id = b.user_id
        JOIN payments p ON p.contribution_id = b.id
        LEFT JOIN rewards r ON r.id = b.reward_id
      WHERE p.state::text = ANY (ARRAY['paid'::character varying::text, 'refunded'::character varying::text, 'pending_refund'::character varying::text]);
    SQL
  end

  def down
    execute <<-SQL
    DROP VIEW "1".contribution_reports;
    CREATE OR REPLACE VIEW contribution_reports AS
      SELECT 
        b.project_id,
        u.name,
        replace(b.value::text, '.'::text, ','::text) AS value,
        replace(r.minimum_value::text, '.'::text, ','::text) AS minimum_value,
        r.description,
        b.payment_method,
        b.acquirer_name,
        b.acquirer_tid,
        b.payment_choice,
        replace(b.payment_service_fee::text, '.'::text, ','::text) AS payment_service_fee,
        b.key,
        b.created_at::date AS created_at,
        b.confirmed_at::date AS confirmed_at,
        u.email,
        b.payer_email,
        b.payer_name,
        COALESCE(b.payer_document, u.cpf) AS cpf,
        u.address_street,
        u.address_complement,
        u.address_number,
        u.address_neighbourhood,
        u.address_city,
        u.address_state,
        u.address_zip_code,
        b.state
      FROM contributions b
        JOIN users u ON u.id = b.user_id
        LEFT JOIN rewards r ON r.id = b.reward_id
      WHERE b.state::text = ANY (ARRAY['confirmed'::character varying::text, 'refunded'::character varying::text, 'requested_refund'::character varying::text]);
    SQL
  end
end
