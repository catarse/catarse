class AddCountryColumnToSubscriptionMonthlyReportForProjectOwners < ActiveRecord::Migration[4.2]
  def up
    execute <<-SQL
      CREATE OR REPLACE VIEW "public"."subscription_monthly_report_for_project_owners" AS
      SELECT
        s.project_id,
        u.name,
        u.public_name,
        u.email,
        REPLACE((ROUND((((s.data ->> 'amount'::TEXT))::NUMERIC / (100)::NUMERIC), 2))::TEXT, '.'::TEXT, ','::TEXT) AS amount,
        REPLACE((ROUND((((((s.data ->> 'amount'::TEXT))::NUMERIC * proj.service_fee) / (100)::NUMERIC) - fees.gateway_fee), 2))::TEXT, '.'::TEXT, ','::TEXT) AS service_fee,
        REPLACE((fees.gateway_fee)::TEXT, '.'::TEXT, ','::TEXT) AS payment_method_fee,
        REPLACE((ROUND(((((s.data ->> 'amount'::TEXT))::NUMERIC - (((s.data ->> 'amount'::TEXT))::NUMERIC * proj.service_fee)) / (100)::NUMERIC), 2))::TEXT, '.'::TEXT, ','::TEXT) AS net_value,
        r.title,
        r.description,
        (s.data ->> 'payment_method'::TEXT) AS payment_method,
        zone_timestamp(s.created_at) AS created_at,
        zone_timestamp(pst.created_at) AS paid_at,
        'Confirmado'::TEXT AS confirmed,
        u.id AS user_id,
        CASE
          WHEN COALESCE(((sub.checkout_data ->> 'anonymous'::TEXT) = 'true'::TEXT), ((s.data ->> 'anonymous'::TEXT) = 'true'::TEXT)) THEN 'sim'::TEXT
          ELSE 'não'::TEXT
        END AS anonymous,
        user_address.street::TEXT,
        user_address.complement::TEXT,
        user_address.number::TEXT,
        user_address.neighborhood::TEXT,
        user_address.city::TEXT,
        user_address.state::TEXT,
        user_address.zipcode::TEXT,
        u.cpf,
        user_address.country::TEXT
      FROM
        common_schema.catalog_payments s
      JOIN users u ON
        u.common_id = s.user_id
      LEFT JOIN rewards r ON
        r.common_id = s.reward_id
      JOIN common_schema.payment_status_transitions pst ON
        pst.catalog_payment_id = s.id AND pst.to_status = 'paid'::payment_service.payment_status
      LEFT JOIN common_schema.subscriptions sub ON
        sub.id = s.subscription_id
      LEFT JOIN projects proj ON
        sub.project_id = proj.common_id
      LEFT JOIN LATERAL (
        SELECT
          ROUND((
            CASE
              WHEN ((s.gateway_general_data ->> 'gateway_payment_method'::TEXT) = 'credit_card'::TEXT)
              THEN (COALESCE(((s.gateway_general_data ->> 'gateway_cost'::TEXT))::NUMERIC, (0)::NUMERIC) + COALESCE(((s.gateway_general_data ->> 'payable_total_fee'::TEXT))::NUMERIC, (0)::NUMERIC))
              ELSE (COALESCE((s.gateway_general_data ->> 'payable_total_fee'::TEXT), (s.gateway_general_data ->> 'gateway_cost'::TEXT), '0'::TEXT))::NUMERIC
            END / (100)::NUMERIC), 2
          ) AS gateway_fee) fees ON TRUE
      LEFT JOIN LATERAL (
        SELECT
          a.id,
          a.address_street AS street,
          a.address_complement AS complement,
          a.address_number AS NUMBER,
          a.address_neighbourhood AS neighborhood,
          a.address_city AS city,
          s.acronym AS state,
          a.address_zip_code AS zipcode,
          country."name" AS country
        FROM
          addresses AS a
        LEFT JOIN states AS s ON
          a.state_id = s.id
        LEFT JOIN countries AS country ON
          country.id = a.country_id
        WHERE
          u.address_id = a.id
        ) user_address ON TRUE
      WHERE
        s.status = 'paid'::payment_service.payment_status
      GROUP BY
        user_address.street,
        user_address.complement,
        user_address.number,
        user_address.neighborhood,
        user_address.city,
        user_address.state,
        user_address.zipcode,
        user_address.country,
        proj.id,
        s.gateway_general_data,
        s.project_id,
        u.name,
        u.public_name,
        u.email,
        s.data,
        r.title,
        r.description,
        s.created_at,
        s.updated_at,
        u.id,
        pst.created_at,
        sub.checkout_data,
        fees.gateway_fee;
    SQL
  end

  def down
    execute <<-SQL
      CREATE OR REPLACE VIEW "public"."subscription_monthly_report_for_project_owners" AS
      SELECT s.project_id,
        u.name,
        u.public_name,
        u.email,
        replace((round((((s.data ->> 'amount'::text))::numeric / (100)::numeric), 2))::text, '.'::text, ','::text) AS amount,
        replace((round((((((s.data ->> 'amount'::text))::numeric * proj.service_fee) / (100)::numeric) - fees.gateway_fee), 2))::text, '.'::text, ','::text) AS service_fee,
        replace((fees.gateway_fee)::text, '.'::text, ','::text) AS payment_method_fee,
        replace((round(((((s.data ->> 'amount'::text))::numeric - (((s.data ->> 'amount'::text))::numeric * proj.service_fee)) / (100)::numeric), 2))::text, '.'::text, ','::text) AS net_value,
        r.title,
        r.description,
        (s.data ->> 'payment_method'::text) AS payment_method,
        zone_timestamp(s.created_at) AS created_at,
        zone_timestamp(pst.created_at) AS paid_at,
        'Confirmado'::text AS confirmed,
        u.id AS user_id,
            CASE
                WHEN COALESCE(((sub.checkout_data ->> 'anonymous'::text) = 'true'::text), ((s.data ->> 'anonymous'::text) = 'true'::text)) THEN 'sim'::text
                ELSE 'não'::text
            END AS anonymous,
        user_address.street::text,
        user_address.complement::text,
        user_address.number::text,
        user_address.neighborhood::text,
        user_address.city::text,
        user_address.state::text,
        user_address.zipcode::text,
        u.cpf
        FROM (((((((common_schema.catalog_payments s
          JOIN users u ON ((u.common_id = s.user_id)))
          LEFT JOIN rewards r ON ((r.common_id = s.reward_id)))
          JOIN common_schema.payment_status_transitions pst ON (((pst.catalog_payment_id = s.id) AND (pst.to_status = 'paid'::payment_service.payment_status))))
          LEFT JOIN common_schema.subscriptions sub ON ((sub.id = s.subscription_id)))
          LEFT JOIN projects proj ON ((sub.project_id = proj.common_id)))
          LEFT JOIN LATERAL ( SELECT round((
                    CASE
                        WHEN ((s.gateway_general_data ->> 'gateway_payment_method'::text) = 'credit_card'::text) THEN (COALESCE(((s.gateway_general_data ->> 'gateway_cost'::text))::numeric, (0)::numeric) + COALESCE(((s.gateway_general_data ->> 'payable_total_fee'::text))::numeric, (0)::numeric))
                        ELSE (COALESCE((s.gateway_general_data ->> 'payable_total_fee'::text), (s.gateway_general_data ->> 'gateway_cost'::text), '0'::text))::numeric
                    END / (100)::numeric), 2) AS gateway_fee) fees ON (true))

            LEFT JOIN LATERAL (

            select
                a.id,
                a.address_street as street,
                a.address_complement as complement,
                a.address_number as number,
                a.address_neighbourhood as neighborhood,
                a.address_city as city,
                s.acronym as state,
                a.address_zip_code as zipcode

            from
                addresses as a left join states as s on a.state_id = s.id where u.address_id = a.id
        ) user_address ON (true))
      WHERE (s.status = 'paid'::payment_service.payment_status)
      GROUP BY
            user_address.street,
            user_address.complement,
            user_address.number,
            user_address.neighborhood,
            user_address.city,
            user_address.state,
            user_address.zipcode,
            proj.id, s.gateway_general_data, s.project_id, u.name, u.public_name, u.email, s.data, r.title, r.description, s.created_at, s.updated_at, u.id, pst.created_at, sub.checkout_data, fees.gateway_fee;

    SQL
  end
end
