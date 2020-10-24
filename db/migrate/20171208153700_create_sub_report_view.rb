class CreateSubReportView < ActiveRecord::Migration[4.2]
  def change
    execute <<-SQL
    create or replace view subscription_report_for_project_owners as
    select s.project_id,
      u.name,
      u.public_name,
      u.email,
      (s.checkout_data->>'amount')::numeric / 100 as amount,
      r.title,
      r.description,
      sum((p.data->>'amount')::numeric) filter (where p.status = 'paid') / 100  as total_backed,
      s.status,
      s.checkout_data->>'payment_method' as payment_method,
      to_char(last_paid_payment.created_at, 'DD/MM/YYYY')last_paid_at,
      to_char(s.created_at, 'DD/MM/YYYY') as started_at,
      count(p.*) filter (where p.status = 'paid') as payments_count,
      u.id as user_id,
      CASE WHEN (last_paid_payment.data->>'anonymous')::bool = true then 'sim' else 'não' end as anonymous,
      s.checkout_data->'customer'->'address'->>'street' as street,
      s.checkout_data->'customer'->'address'->>'complementary' as complement,
      s.checkout_data->'customer'->'address'->>'street_number' as number,
      s.checkout_data->'customer'->'address'->>'neighborhood' as neighborhood,
      s.checkout_data->'customer'->'address'->>'city' as city,
      s.checkout_data->'customer'->'address'->>'state' as state,
      s.checkout_data->'customer'->'address'->>'zipcode' as zipcode

    from common_schema.subscriptions s
    join users u on u.common_id = s.user_id
    LEFT JOIN common_schema.catalog_payments p on p.subscription_id = s.id
    LEFT JOIN rewards r on r.common_id = s.reward_id
    LEFT JOIN LATERAL ( SELECT cp.id,
            cp.data,
            cp.created_at
           FROM common_schema.catalog_payments cp
          WHERE cp.subscription_id = s.id AND cp.status = 'paid'
          ORDER BY cp.created_at DESC
         LIMIT 1) last_paid_payment ON true
    group by s.project_id, u.name, u.public_name, u.email, s.checkout_data, r.title, r.description, p.data,
      s.status, last_paid_payment.created_at,s.created_at, u.id, last_paid_payment.data;
    SQL
  end
end
