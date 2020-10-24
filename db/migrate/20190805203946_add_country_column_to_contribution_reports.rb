class AddCountryColumnToContributionReports < ActiveRecord::Migration[4.2]
  def up
    execute <<-SQL
      CREATE OR REPLACE VIEW "1".contribution_reports AS
      SELECT
        b.project_id,
        u.name,
        replace(b.value::text, '.'::text, ','::text) AS value,
        replace(r.minimum_value::text, '.'::text, ','::text) AS minimum_value,
        r.description,
        p.gateway,
        p.gateway_data -> 'acquirer_name'::text AS acquirer_name,
        p.gateway_data -> 'tid'::text AS acquirer_tid,
        p.payment_method,
        replace(p.gateway_fee::text, '.'::text, ','::text) AS payment_service_fee,
        p.key,
        b.created_at::date AS created_at,
        p.paid_at::date AS confirmed_at,
        u.email,
        b.payer_email,
        b.payer_name,
        COALESCE(b.payer_document, u.cpf) AS cpf,
        add.address_street,
        add.address_complement,
        add.address_number,
        add.address_neighbourhood,
        add.address_city,
        add.address_state,
        add.address_zip_code,
        p.state,
        country.name as address_country
      FROM
        contributions b
      JOIN
        users u ON u.id = b.user_id
      JOIN
        payments p ON p.contribution_id = b.id
      LEFT JOIN
        rewards r ON r.id = b.reward_id
      LEFT JOIN
        addresses add ON add.id = u.address_id
      LEFT JOIN
        countries country ON add.country_id = country.id
      WHERE
        p.state = ANY(ARRAY[
          'paid'::character varying::text,
          'refunded'::character varying::text,
          'pending_refund'::character varying::text
        ])
      ;
    SQL
  end

  def down
    execute <<-SQL
      CREATE OR REPLACE VIEW "1".contribution_reports AS
      SELECT
        b.project_id,
        u.name,
        replace(b.value::text, '.'::text, ','::text) AS value,
        replace(r.minimum_value::text, '.'::text, ','::text) AS minimum_value,
        r.description,
        p.gateway,
        p.gateway_data -> 'acquirer_name'::text AS acquirer_name,
        p.gateway_data -> 'tid'::text AS acquirer_tid,
        p.payment_method,
        replace(p.gateway_fee::text, '.'::text, ','::text) AS payment_service_fee,
        p.key,
        b.created_at::date AS created_at,
        p.paid_at::date AS confirmed_at,
        u.email,
        b.payer_email,
        b.payer_name,
        COALESCE(b.payer_document, u.cpf) AS cpf,
        add.address_street,
        add.address_complement,
        add.address_number,
        add.address_neighbourhood,
        add.address_city,
        add.address_state,
        add.address_zip_code,
        p.state
      FROM
        contributions b
      JOIN
        users u ON u.id = b.user_id
      JOIN
        payments p ON p.contribution_id = b.id
      LEFT JOIN
        rewards r ON r.id = b.reward_id
      LEFT JOIN
        addresses add ON add.id = u.address_id
      WHERE
        p.state = ANY(ARRAY[
          'paid'::character varying::text,
          'refunded'::character varying::text,
          'pending_refund'::character varying::text
        ])
      ;
    SQL
  end
end
