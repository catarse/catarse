class UseSubscriptionAnonymousStatusForReports < ActiveRecord::Migration[4.2]
  def up
    execute <<-SQL

      CREATE OR REPLACE VIEW "public"."subscription_report_for_project_owners" AS
        SELECT s.project_id,
            u.name,
            u.public_name,
            u.email,
            (((s.checkout_data ->> 'amount'::text))::numeric / (100)::numeric) AS amount,
            r.title,
            r.description,
            (sum(((p.data ->> 'amount'::text))::numeric) FILTER (WHERE (p.status = 'paid'::payment_service.payment_status)) / (100)::numeric) AS total_backed,
            s.status,
            (s.checkout_data ->> 'payment_method'::text) AS payment_method,
            to_char(last_paid_payment.created_at, 'DD/MM/YYYY'::text) AS last_paid_at,
            to_char(s.created_at, 'DD/MM/YYYY'::text) AS started_at,
            count(p.*) FILTER (WHERE (p.status = 'paid'::payment_service.payment_status)) AS payments_count,
            u.id AS user_id,
                CASE
                    WHEN (((s.checkout_data ->> 'anonymous'::text))::boolean = true) THEN 'sim'::text
                    ELSE 'não'::text
                END AS anonymous,
            (((s.checkout_data -> 'customer'::text) -> 'address'::text) ->> 'street'::text) AS street,
            (((s.checkout_data -> 'customer'::text) -> 'address'::text) ->> 'complementary'::text) AS complement,
            (((s.checkout_data -> 'customer'::text) -> 'address'::text) ->> 'street_number'::text) AS number,
            (((s.checkout_data -> 'customer'::text) -> 'address'::text) ->> 'neighborhood'::text) AS neighborhood,
            (((s.checkout_data -> 'customer'::text) -> 'address'::text) ->> 'city'::text) AS city,
            (((s.checkout_data -> 'customer'::text) -> 'address'::text) ->> 'state'::text) AS state,
            (((s.checkout_data -> 'customer'::text) -> 'address'::text) ->> 'zipcode'::text) AS zipcode,
            u.cpf
          FROM ((((common_schema.subscriptions s
            JOIN users u ON ((u.common_id = s.user_id)))
            LEFT JOIN common_schema.catalog_payments p ON ((p.subscription_id = s.id)))
            LEFT JOIN rewards r ON ((r.common_id = s.reward_id)))
            LEFT JOIN LATERAL ( SELECT cp.id,
                    cp.data,
                    cp.created_at
                  FROM common_schema.catalog_payments cp
                  WHERE ((cp.subscription_id = s.id) AND (cp.status = 'paid'::payment_service.payment_status))
                  ORDER BY cp.created_at DESC
                LIMIT 1) last_paid_payment ON (true))
          WHERE (s.status <> 'deleted'::payment_service.subscription_status)
          GROUP BY s.project_id, u.name, u.public_name, u.email, s.checkout_data, r.title, r.description, s.status, last_paid_payment.created_at, s.created_at, u.id, last_paid_payment.data;;
      ;;

      CREATE OR REPLACE VIEW "public"."subscription_monthly_report_for_project_owners" AS
        SELECT s.project_id,
            u.name,
            u.public_name,
            u.email,
            (((s.data ->> 'amount'::text))::numeric / (100)::numeric) AS amount,
            r.title,
            r.description,
            (s.data ->> 'payment_method'::text) AS payment_method,
            zone_timestamp(s.created_at) AS created_at,
            zone_timestamp(pst.created_at) AS paid_at,
            'Confirmado'::text AS confirmed,
            u.id AS user_id,
                CASE
                    WHEN (COALESCE(sub.checkout_data ->> 'anonymous' = 'true', s.data ->> 'anonymous' = 'true')) THEN 'sim'::text
                    ELSE 'não'::text
                END AS anonymous,
            (((s.data -> 'customer'::text) -> 'address'::text) ->> 'street'::text) AS street,
            (((s.data -> 'customer'::text) -> 'address'::text) ->> 'complementary'::text) AS complement,
            (((s.data -> 'customer'::text) -> 'address'::text) ->> 'street_number'::text) AS number,
            (((s.data -> 'customer'::text) -> 'address'::text) ->> 'neighborhood'::text) AS neighborhood,
            (((s.data -> 'customer'::text) -> 'address'::text) ->> 'city'::text) AS city,
            (((s.data -> 'customer'::text) -> 'address'::text) ->> 'state'::text) AS state,
            (((s.data -> 'customer'::text) -> 'address'::text) ->> 'zipcode'::text) AS zipcode,
            u.cpf
          FROM common_schema.catalog_payments s
            JOIN users u ON u.common_id = s.user_id
            LEFT JOIN rewards r ON r.common_id = s.reward_id
            JOIN common_schema.payment_status_transitions pst ON (pst.catalog_payment_id = s.id AND pst.to_status = 'paid'::payment_service.payment_status)
            LEFT JOIN common_schema.subscriptions sub ON sub.id = s.subscription_id
          WHERE s.status = 'paid'::payment_service.payment_status
          GROUP BY s.project_id, u.name, u.public_name, u.email, s.data, r.title, r.description, s.created_at, s.updated_at, u.id, pst.created_at, sub.checkout_data;;
      ;;
    SQL
  end

  def down
    execute <<-SQL

      CREATE OR REPLACE VIEW "public"."subscription_report_for_project_owners" AS
        SELECT s.project_id,
            u.name,
            u.public_name,
            u.email,
            (((s.checkout_data ->> 'amount'::text))::numeric / (100)::numeric) AS amount,
            r.title,
            r.description,
            (sum(((p.data ->> 'amount'::text))::numeric) FILTER (WHERE (p.status = 'paid'::payment_service.payment_status)) / (100)::numeric) AS total_backed,
            s.status,
            (s.checkout_data ->> 'payment_method'::text) AS payment_method,
            to_char(last_paid_payment.created_at, 'DD/MM/YYYY'::text) AS last_paid_at,
            to_char(s.created_at, 'DD/MM/YYYY'::text) AS started_at,
            count(p.*) FILTER (WHERE (p.status = 'paid'::payment_service.payment_status)) AS payments_count,
            u.id AS user_id,
                CASE
                    WHEN (((last_paid_payment.data ->> 'anonymous'::text))::boolean = true) THEN 'sim'::text
                    ELSE 'não'::text
                END AS anonymous,
            (((s.checkout_data -> 'customer'::text) -> 'address'::text) ->> 'street'::text) AS street,
            (((s.checkout_data -> 'customer'::text) -> 'address'::text) ->> 'complementary'::text) AS complement,
            (((s.checkout_data -> 'customer'::text) -> 'address'::text) ->> 'street_number'::text) AS number,
            (((s.checkout_data -> 'customer'::text) -> 'address'::text) ->> 'neighborhood'::text) AS neighborhood,
            (((s.checkout_data -> 'customer'::text) -> 'address'::text) ->> 'city'::text) AS city,
            (((s.checkout_data -> 'customer'::text) -> 'address'::text) ->> 'state'::text) AS state,
            (((s.checkout_data -> 'customer'::text) -> 'address'::text) ->> 'zipcode'::text) AS zipcode,
            u.cpf
          FROM ((((common_schema.subscriptions s
            JOIN users u ON ((u.common_id = s.user_id)))
            LEFT JOIN common_schema.catalog_payments p ON ((p.subscription_id = s.id)))
            LEFT JOIN rewards r ON ((r.common_id = s.reward_id)))
            LEFT JOIN LATERAL ( SELECT cp.id,
                    cp.data,
                    cp.created_at
                  FROM common_schema.catalog_payments cp
                  WHERE ((cp.subscription_id = s.id) AND (cp.status = 'paid'::payment_service.payment_status))
                  ORDER BY cp.created_at DESC
                LIMIT 1) last_paid_payment ON (true))
          WHERE (s.status <> 'deleted'::payment_service.subscription_status)
          GROUP BY s.project_id, u.name, u.public_name, u.email, s.checkout_data, r.title, r.description, s.status, last_paid_payment.created_at, s.created_at, u.id, last_paid_payment.data;;
      ;;

      CREATE OR REPLACE VIEW "public"."subscription_monthly_report_for_project_owners" AS
      SELECT s.project_id,
       u.name,
       u.public_name,
       u.email,
       (((s.data ->> 'amount'::text))::numeric / (100)::numeric) AS amount,
       r.title,
       r.description,
       (s.data ->> 'payment_method'::text) AS payment_method,
       zone_timestamp(s.created_at) created_at,
       zone_timestamp(pst.created_at) as paid_at,
       'Confirmado'::text AS confirmed,
       u.id AS user_id,
           CASE
               WHEN (((s.data ->> 'anonymous'::text))::boolean = true) THEN 'sim'::text
               ELSE 'não'::text
           END AS anonymous,
       (((s.data -> 'customer'::text) -> 'address'::text) ->> 'street'::text) AS street,
       (((s.data -> 'customer'::text) -> 'address'::text) ->> 'complementary'::text) AS complement,
       (((s.data -> 'customer'::text) -> 'address'::text) ->> 'street_number'::text) AS number,
       (((s.data -> 'customer'::text) -> 'address'::text) ->> 'neighborhood'::text) AS neighborhood,
       (((s.data -> 'customer'::text) -> 'address'::text) ->> 'city'::text) AS city,
       (((s.data -> 'customer'::text) -> 'address'::text) ->> 'state'::text) AS state,
       (((s.data -> 'customer'::text) -> 'address'::text) ->> 'zipcode'::text) AS zipcode,
       u.cpf
      FROM ((common_schema.catalog_payments s
        JOIN users u ON ((u.common_id = s.user_id)))
        LEFT JOIN rewards r ON ((r.common_id = s.reward_id)))
        JOIN common_schema.payment_status_transitions pst on pst.catalog_payment_id=s.id and pst.to_status='paid'
     WHERE (s.status = 'paid'::payment_service.payment_status)
     GROUP BY s.project_id, u.name, u.public_name, u.email, s.data, r.title, r.description, s.created_at, s.updated_at, u.id, pst.created_at;
     ;;
    SQL
  end
end
