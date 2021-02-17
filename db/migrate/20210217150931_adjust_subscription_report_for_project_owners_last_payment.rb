class AdjustSubscriptionReportForProjectOwnersLastPayment < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
CREATE OR REPLACE VIEW "subscription_report_for_project_owners" AS 
 SELECT s.project_id,
    u.name,
    u.public_name,
    u.email,
    (((last_paid_payment.checkout_data ->> 'amount'::text))::numeric / (100)::numeric) AS amount,
    r.title,
    r.description,
    (sum(((p.data ->> 'amount'::text))::numeric) FILTER (WHERE (p.status = 'paid'::payment_service.payment_status)) / (100)::numeric) AS total_backed,
    s.status,
    COALESCE((last_paid_payment.checkout_data ->> 'payment_method'::text), (last_payment.checkout_data ->> 'payment_method'::text)) AS payment_method,
    to_char(last_paid_payment.created_at, 'DD/MM/YYYY'::text) AS last_paid_at,
    to_char(s.created_at, 'DD/MM/YYYY'::text) AS started_at,
    count(p.*) FILTER (WHERE (p.status = 'paid'::payment_service.payment_status)) AS payments_count,
    u.id AS user_id,
        CASE
            WHEN (((last_paid_payment.checkout_data ->> 'anonymous'::text))::boolean = true) THEN 'sim'::text
            ELSE 'não'::text
        END AS anonymous,
    user_address.street,
    user_address.complement,
    user_address.number,
    user_address.neighborhood,
    user_address.city,
    (user_address.state)::text AS state,
    user_address.zipcode,
    u.cpf,
    user_address.country
   FROM (((((((common_schema.subscriptions s
     JOIN users u ON ((u.common_id = s.user_id)))
     LEFT JOIN common_schema.catalog_payments p ON ((p.subscription_id = s.id)))
     LEFT JOIN LATERAL ( SELECT count(1) FILTER (WHERE (cp.status = 'paid'::payment_service.payment_status)) AS paid_count
           FROM common_schema.catalog_payments cp
          WHERE (cp.subscription_id = s.id)
         LIMIT 1) stats ON (true))
     LEFT JOIN LATERAL ( SELECT cp.id,
            COALESCE(cp.data, s.checkout_data) AS checkout_data,
            cp.created_at,
            cp.reward_id
           FROM common_schema.catalog_payments cp
          WHERE ((cp.subscription_id = s.id) AND (cp.status = 'paid'::payment_service.payment_status))
          ORDER BY cp.created_at DESC
         LIMIT 1) last_paid_payment ON (true))
     LEFT JOIN LATERAL ( SELECT cp.id,
            COALESCE(cp.data, s.checkout_data) AS checkout_data,
            cp.created_at,
            cp.reward_id
           FROM common_schema.catalog_payments cp
          WHERE ((cp.subscription_id = s.id) AND (cp.status <> 'deleted'::payment_service.payment_status))
          ORDER BY cp.created_at DESC
         LIMIT 1) last_payment ON (true))
     LEFT JOIN LATERAL ( SELECT reward.title,
            reward.description
           FROM rewards reward
          WHERE (((reward.common_id = s.reward_id) AND (stats.paid_count = 0)) OR ((reward.common_id = last_paid_payment.reward_id) AND (stats.paid_count > 0)))
         LIMIT 1) r ON (true))
     LEFT JOIN LATERAL ( SELECT a.id,
            a.address_street AS street,
            a.address_complement AS complement,
            a.address_number AS number,
            a.address_neighbourhood AS neighborhood,
            a.address_city AS city,
            s_1.acronym AS state,
            a.address_zip_code AS zipcode,
            country.name AS country
           FROM ((addresses a
             LEFT JOIN states s_1 ON ((a.state_id = s_1.id)))
             LEFT JOIN countries country ON ((country.id = a.country_id)))
          WHERE (u.address_id = a.id)) user_address ON (true))
  WHERE (s.status <> 'deleted'::payment_service.subscription_status)
  GROUP BY user_address.street, user_address.complement, user_address.number, user_address.neighborhood, user_address.city, user_address.state, user_address.zipcode, user_address.country, s.project_id, u.name, u.public_name, u.email, last_paid_payment.checkout_data, last_payment.checkout_data, r.title, r.description, s.status, last_paid_payment.created_at, s.created_at, u.id;
    SQL
  end

  def down
    execute <<-SQL
CREATE OR REPLACE VIEW "subscription_report_for_project_owners_backup" AS 
 SELECT s.project_id,
    u.name,
    u.public_name,
    u.email,
    (((last_paid_payment.checkout_data ->> 'amount'::text))::numeric / (100)::numeric) AS amount,
    r.title,
    r.description,
    (sum(((p.data ->> 'amount'::text))::numeric) FILTER (WHERE (p.status = 'paid'::payment_service.payment_status)) / (100)::numeric) AS total_backed,
    s.status,
    (last_paid_payment.checkout_data ->> 'payment_method'::text) AS payment_method,
    to_char(last_paid_payment.created_at, 'DD/MM/YYYY'::text) AS last_paid_at,
    to_char(s.created_at, 'DD/MM/YYYY'::text) AS started_at,
    count(p.*) FILTER (WHERE (p.status = 'paid'::payment_service.payment_status)) AS payments_count,
    u.id AS user_id,
        CASE
            WHEN (((last_paid_payment.checkout_data ->> 'anonymous'::text))::boolean = true) THEN 'sim'::text
            ELSE 'não'::text
        END AS anonymous,
    user_address.street,
    user_address.complement,
    user_address.number,
    user_address.neighborhood,
    user_address.city,
    (user_address.state)::text AS state,
    user_address.zipcode,
    u.cpf,
    user_address.country
   FROM ((((((common_schema.subscriptions s
     JOIN users u ON ((u.common_id = s.user_id)))
     LEFT JOIN common_schema.catalog_payments p ON ((p.subscription_id = s.id)))
     LEFT JOIN LATERAL ( SELECT count(1) FILTER (WHERE (cp.status = 'paid'::payment_service.payment_status)) AS paid_count
           FROM common_schema.catalog_payments cp
          WHERE (cp.subscription_id = s.id)
         LIMIT 1) stats ON (true))
     LEFT JOIN LATERAL ( SELECT cp.id,
            COALESCE(cp.data, s.checkout_data) AS checkout_data,
            cp.created_at,
            cp.reward_id
           FROM common_schema.catalog_payments cp
          WHERE ((cp.subscription_id = s.id) AND (cp.status = 'paid'::payment_service.payment_status))
          ORDER BY cp.created_at DESC
         LIMIT 1) last_paid_payment ON (true))
     LEFT JOIN LATERAL ( SELECT reward.title,
            reward.description
           FROM rewards reward
          WHERE (((reward.common_id = s.reward_id) AND (stats.paid_count = 0)) OR ((reward.common_id = last_paid_payment.reward_id) AND (stats.paid_count > 0)))
         LIMIT 1) r ON (true))
     LEFT JOIN LATERAL ( SELECT a.id,
            a.address_street AS street,
            a.address_complement AS complement,
            a.address_number AS number,
            a.address_neighbourhood AS neighborhood,
            a.address_city AS city,
            s_1.acronym AS state,
            a.address_zip_code AS zipcode,
            country.name AS country
           FROM ((addresses a
             LEFT JOIN states s_1 ON ((a.state_id = s_1.id)))
             LEFT JOIN countries country ON ((country.id = a.country_id)))
          WHERE (u.address_id = a.id)) user_address ON (true))
  WHERE (s.status <> 'deleted'::payment_service.subscription_status)
  GROUP BY user_address.street, user_address.complement, user_address.number, user_address.neighborhood, user_address.city, user_address.state, user_address.zipcode, user_address.country, s.project_id, u.name, u.public_name, u.email, last_paid_payment.checkout_data, r.title, r.description, s.status, last_paid_payment.created_at, s.created_at, u.id;
    SQL
  end
end
