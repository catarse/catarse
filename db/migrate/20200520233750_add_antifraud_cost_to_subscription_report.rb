class AddAntifraudCostToSubscriptionReport < ActiveRecord::Migration[4.2]
  def up
    execute <<-SQL
      DROP VIEW public.subscription_monthly_report_for_project_owners;
      CREATE VIEW public.subscription_monthly_report_for_project_owners AS
        SELECT s.project_id,
        u.name,
        u.public_name,
        u.email,
        replace(round(((s.data ->> 'amount'::text)::numeric) / 100::numeric, 2)::text, '.'::text, ','::text) AS amount,
        replace(round(((s.data ->> 'amount'::text)::numeric) * proj.service_fee / 100::numeric - fees.gateway_fee - COALESCE(aa."cost", 0.0), 2)::text, '.'::text, ','::text) AS service_fee,
        replace(fees.gateway_fee::text, '.'::text, ','::text) AS payment_method_fee,
        replace(COALESCE(aa."cost", 0.0)::text, '.'::text, ','::TEXT) AS antifraud_cost,
        replace(round((((s.data ->> 'amount'::text)::numeric) - ((s.data ->> 'amount'::text)::numeric) * proj.service_fee) / 100::numeric, 2)::text, '.'::text, ','::text) AS net_value,
        r.title,
        r.description,
        s.data ->> 'payment_method'::text AS payment_method,
        s.created_at,
        pst.created_at AS paid_at,
        'Confirmado'::text AS confirmed,
        u.id AS user_id,
            CASE
                WHEN COALESCE((sub.checkout_data ->> 'anonymous'::text) = 'true'::text, (s.data ->> 'anonymous'::text) = 'true'::text) THEN 'sim'::text
                ELSE 'não'::text
            END AS anonymous,
        user_address.street,
        user_address.complement,
        user_address.number,
        user_address.neighborhood,
        user_address.city,
        user_address.state::text AS state,
        user_address.zipcode,
        u.cpf,
        user_address.country
        FROM common_schema.catalog_payments s
        JOIN users u ON u.common_id = s.user_id
        LEFT JOIN rewards r ON r.common_id = s.reward_id
        LEFT JOIN common_schema.antifraud_analyses aa ON s.id = aa.catalog_payment_id
        LEFT JOIN LATERAL ( SELECT pst2.id,
                pst2.catalog_payment_id,
                pst2.from_status,
                pst2.to_status,
                pst2.data,
                pst2.created_at,
                pst2.updated_at
              FROM common_schema.payment_status_transitions pst2
              WHERE pst2.catalog_payment_id = s.id AND pst2.to_status = 'paid'::payment_service.payment_status
            LIMIT 1) pst ON true
        LEFT JOIN common_schema.subscriptions sub ON sub.id = s.subscription_id
        LEFT JOIN projects proj ON sub.project_id = proj.common_id
        LEFT JOIN LATERAL ( SELECT round(
                    CASE
                        WHEN (s.gateway_general_data ->> 'gateway_payment_method'::text) = 'credit_card'::text
                        THEN
                          COALESCE((s.gateway_general_data ->> 'gateway_cost'::text)::numeric, 0::numeric) + COALESCE((s.gateway_general_data ->> 'payable_total_fee'::text)::numeric, 0::numeric)
                        ELSE
                          COALESCE(s.gateway_general_data ->> 'payable_total_fee'::text, s.gateway_general_data ->> 'gateway_cost'::text, '0'::text)::numeric
                    END / 100::numeric, 2) AS gateway_fee) fees ON true
        LEFT JOIN LATERAL ( SELECT a.id,
                a.address_street AS street,
                a.address_complement AS complement,
                a.address_number AS number,
                a.address_neighbourhood AS neighborhood,
                a.address_city AS city,
                s_1.acronym AS state,
                a.address_zip_code AS zipcode,
                country.name AS country
              FROM addresses a
                LEFT JOIN states s_1 ON a.state_id = s_1.id
                LEFT JOIN countries country ON country.id = a.country_id
              WHERE u.address_id = a.id) user_address ON true
        WHERE s.status = 'paid'::payment_service.payment_status AND sub.status <> 'deleted'::payment_service.subscription_status
        GROUP BY user_address.street, user_address.complement, user_address.number, user_address.neighborhood, user_address.city, user_address.state, user_address.zipcode, user_address.country, proj.id, s.gateway_general_data, s.project_id, u.name, u.public_name, u.email, s.data, r.title, r.description, s.created_at, s.updated_at, u.id, pst.created_at, sub.checkout_data, fees.gateway_fee, aa."cost";
    SQL
  end

  def down
    execute <<-SQL
      DROP VIEW public.subscription_monthly_report_for_project_owners;
      CREATE VIEW public.subscription_monthly_report_for_project_owners AS
        SELECT s.project_id,
        u.name,
        u.public_name,
        u.email,
        replace(round(((s.data ->> 'amount'::text)::numeric) / 100::numeric, 2)::text, '.'::text, ','::text) AS amount,
        replace(round(((s.data ->> 'amount'::text)::numeric) * proj.service_fee / 100::numeric - fees.gateway_fee, 2)::text, '.'::text, ','::text) AS service_fee,
        replace(fees.gateway_fee::text, '.'::text, ','::text) AS payment_method_fee,
        replace(round((((s.data ->> 'amount'::text)::numeric) - ((s.data ->> 'amount'::text)::numeric) * proj.service_fee) / 100::numeric, 2)::text, '.'::text, ','::text) AS net_value,
        r.title,
        r.description,
        s.data ->> 'payment_method'::text AS payment_method,
        s.created_at,
        pst.created_at AS paid_at,
        'Confirmado'::text AS confirmed,
        u.id AS user_id,
            CASE
                WHEN COALESCE((sub.checkout_data ->> 'anonymous'::text) = 'true'::text, (s.data ->> 'anonymous'::text) = 'true'::text) THEN 'sim'::text
                ELSE 'não'::text
            END AS anonymous,
        user_address.street,
        user_address.complement,
        user_address.number,
        user_address.neighborhood,
        user_address.city,
        user_address.state::text AS state,
        user_address.zipcode,
        u.cpf,
        user_address.country
       FROM common_schema.catalog_payments s
         JOIN users u ON u.common_id = s.user_id
         LEFT JOIN rewards r ON r.common_id = s.reward_id
         LEFT JOIN LATERAL ( SELECT pst2.id,
                pst2.catalog_payment_id,
                pst2.from_status,
                pst2.to_status,
                pst2.data,
                pst2.created_at,
                pst2.updated_at
               FROM common_schema.payment_status_transitions pst2
              WHERE pst2.catalog_payment_id = s.id AND pst2.to_status = 'paid'::payment_service.payment_status
             LIMIT 1) pst ON true
         LEFT JOIN common_schema.subscriptions sub ON sub.id = s.subscription_id
         LEFT JOIN projects proj ON sub.project_id = proj.common_id
         LEFT JOIN LATERAL ( SELECT round(
                    CASE
                        WHEN (s.gateway_general_data ->> 'gateway_payment_method'::text) = 'credit_card'::text THEN COALESCE((s.gateway_general_data ->> 'gateway_cost'::text)::numeric, 0::numeric) + COALESCE((s.gateway_general_data ->> 'payable_total_fee'::text)::numeric, 0::numeric)
                        ELSE COALESCE(s.gateway_general_data ->> 'payable_total_fee'::text, s.gateway_general_data ->> 'gateway_cost'::text, '0'::text)::numeric
                    END / 100::numeric, 2) AS gateway_fee) fees ON true
         LEFT JOIN LATERAL ( SELECT a.id,
                a.address_street AS street,
                a.address_complement AS complement,
                a.address_number AS number,
                a.address_neighbourhood AS neighborhood,
                a.address_city AS city,
                s_1.acronym AS state,
                a.address_zip_code AS zipcode,
                country.name AS country
               FROM addresses a
                 LEFT JOIN states s_1 ON a.state_id = s_1.id
                 LEFT JOIN countries country ON country.id = a.country_id
              WHERE u.address_id = a.id) user_address ON true
      WHERE s.status = 'paid'::payment_service.payment_status AND sub.status <> 'deleted'::payment_service.subscription_status
      GROUP BY user_address.street, user_address.complement, user_address.number, user_address.neighborhood, user_address.city, user_address.state, user_address.zipcode, user_address.country, proj.id, s.gateway_general_data, s.project_id, u.name, u.public_name, u.email, s.data, r.title, r.description, s.created_at, s.updated_at, u.id, pst.created_at, sub.checkout_data, fees.gateway_fee;
    SQL
  end
end
