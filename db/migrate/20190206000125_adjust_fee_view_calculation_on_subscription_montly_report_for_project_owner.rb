class AdjustFeeViewCalculationOnSubscriptionMontlyReportForProjectOwner < ActiveRecord::Migration[4.2]
  def up
    execute <<-SQL
    DROP VIEW subscription_monthly_report_for_project_owners;
    CREATE OR REPLACE VIEW subscription_monthly_report_for_project_owners AS
SELECT s.project_id,
       u.name,
       u.public_name,
       u.email,
       replace((round((((s.data ->> 'amount'::text))::numeric / (100)::numeric), 2))::text, '.'::text, ','::text) AS amount,
       replace((round(((((((s.data ->> 'amount'::text))::numeric * proj.service_fee) / (100)::numeric) - (fees.gateway_fee)::numeric)), 2))::text,'.'::text, ','::text) AS service_fee,
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
         WHEN COALESCE(((sub.checkout_data ->> 'anonymous'::text) = 'true'::text),
                       ((s.data ->> 'anonymous'::text) = 'true'::text)) THEN 'sim'::text
         ELSE 'não'::text
         END                                                                         AS anonymous,
       (((s.data -> 'customer'::text) -> 'address'::text) ->> 'street'::text)        AS street,
       (((s.data -> 'customer'::text) -> 'address'::text) ->> 'complementary'::text) AS complement,
       (((s.data -> 'customer'::text) -> 'address'::text) ->> 'street_number'::text) AS number,
       (((s.data -> 'customer'::text) -> 'address'::text) ->> 'neighborhood'::text)  AS neighborhood,
       (((s.data -> 'customer'::text) -> 'address'::text) ->> 'city'::text)          AS city,
       (((s.data -> 'customer'::text) -> 'address'::text) ->> 'state'::text)         AS state,
       (((s.data -> 'customer'::text) -> 'address'::text) ->> 'zipcode'::text)       AS zipcode,
       u.cpf
FROM (((((common_schema.catalog_payments s
  JOIN users u ON ((u.common_id = s.user_id)))
  LEFT JOIN rewards r ON ((r.common_id = s.reward_id)))
  JOIN common_schema.payment_status_transitions pst ON (((pst.catalog_payment_id = s.id) AND
                                                         (pst.to_status = 'paid'::payment_service.payment_status))))
  LEFT JOIN common_schema.subscriptions sub ON ((sub.id = s.subscription_id)))
  LEFT JOIN projects proj ON ((sub.project_id = proj.common_id)))
  LEFT JOIN LATERAL (
    select
       round((CASE WHEN (s.gateway_general_data->>'gateway_payment_method')='credit_card'
 THEN COALESCE((s.gateway_general_data ->> 'gateway_cost')::numeric,0)
     +COALESCE((s.gateway_general_data->>'payable_total_fee')::numeric,0)
 ELSE coalesce((s.gateway_general_data->>'payable_total_fee'),(s.gateway_general_data ->> 'gateway_cost'),'0')::numeric
 END)/100,2) as gateway_fee
  ) fees on true
WHERE (s.status = 'paid'::payment_service.payment_status)
GROUP BY proj.id, s.gateway_general_data, s.project_id, u.name, u.public_name, u.email, s.data, r.title, r.description,
         s.created_at, s.updated_at, u.id, pst.created_at, sub.checkout_data, fees.gateway_fee;

    grant select on subscription_monthly_report_for_project_owners to admin, web_user;
    SQL
  end

  def down
    execute <<-SQL
    DROP VIEW subscription_monthly_report_for_project_owners;
    CREATE OR REPLACE VIEW subscription_monthly_report_for_project_owners AS
    SELECT s.project_id,
      u.name,
      u.public_name,
      u.email,
        replace(round((((s.data ->> 'amount'::text))::numeric / (100)::numeric), 2)::text, '.', ',') AS amount,
        replace(round(((s.data->>'amount'::text)::numeric * proj.service_fee - (s.gateway_general_data->>'gateway_cost'::text)::numeric) / 100, 2)::text, '.', ',')   as service_fee,
        replace(round((s.gateway_general_data->>'gateway_cost'::text)::numeric / 100, 2)::text, '.', ',')   as payment_method_fee,
        replace(round(((s.data->>'amount'::text)::numeric - (s.data->>'amount'::text)::numeric * proj.service_fee) / 100, 2)::text, '.', ',')  as net_value,
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
      (((s.data -> 'customer'::text) -> 'address'::text) ->> 'street'::text) AS street,
      (((s.data -> 'customer'::text) -> 'address'::text) ->> 'complementary'::text) AS complement,
      (((s.data -> 'customer'::text) -> 'address'::text) ->> 'street_number'::text) AS number,
      (((s.data -> 'customer'::text) -> 'address'::text) ->> 'neighborhood'::text) AS neighborhood,
      (((s.data -> 'customer'::text) -> 'address'::text) ->> 'city'::text) AS city,
      (((s.data -> 'customer'::text) -> 'address'::text) ->> 'state'::text) AS state,
      (((s.data -> 'customer'::text) -> 'address'::text) ->> 'zipcode'::text) AS zipcode,
      u.cpf
    FROM ((((common_schema.catalog_payments s
      JOIN users u ON ((u.common_id = s.user_id)))
      LEFT JOIN rewards r ON ((r.common_id = s.reward_id)))
      JOIN common_schema.payment_status_transitions pst ON (((pst.catalog_payment_id = s.id) AND (pst.to_status = 'paid'::payment_service.payment_status))))
      LEFT JOIN common_schema.subscriptions sub ON ((sub.id = s.subscription_id)))
      LEFT JOIN projects proj ON sub.project_id = proj.common_id
    WHERE (s.status = 'paid'::payment_service.payment_status)
    GROUP BY proj.id, s.gateway_general_data, s.project_id, u.name, u.public_name, u.email, s.data, r.title, r.description, s.created_at, s.updated_at, u.id, pst.created_at, sub.checkout_data;

    grant select on subscription_monthly_report_for_project_owners to admin, web_user;
    SQL
  end
end
