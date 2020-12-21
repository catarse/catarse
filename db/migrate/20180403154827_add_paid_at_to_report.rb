class AddPaidAtToReport < ActiveRecord::Migration[4.2]
  def change
    execute <<-SQL
  drop view "public"."subscription_monthly_report_for_project_owners";
  CREATE OR REPLACE VIEW "public"."subscription_monthly_report_for_project_owners" AS
   SELECT s.project_id,
    u.name,
    u.public_name,
    u.email,
    (((s.data ->> 'amount'::text))::numeric / (100)::numeric) AS amount,
    r.title,
    r.description,
    (s.data ->> 'payment_method'::text) AS payment_method,
    s.created_at,
    s.updated_at as paid_at,
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
  WHERE (s.status = 'paid'::payment_service.payment_status)
  GROUP BY s.project_id, u.name, u.public_name, u.email, s.data, r.title, r.description, s.created_at, s.updated_at, u.id;
    SQL
  end
end
