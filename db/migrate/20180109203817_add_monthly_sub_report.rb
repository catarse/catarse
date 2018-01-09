# coding: utf-8
class AddMonthlySubReport < ActiveRecord::Migration
  def change
    execute <<-SQL
    create or replace view subscription_monthly_report_for_project_owners as
    select s.project_id,
      u.name,
      u.public_name,
      u.email,
      (s.data->>'amount')::numeric / 100 as amount,
      r.title,
      r.description,
      s.data->>'payment_method' as payment_method,
      s.created_at as created_at,
      'Confirmado'::text as confirmed,
      u.id as user_id,
      CASE WHEN (s.data->>'anonymous')::bool = true then 'sim' else 'não' end as anonymous,
      s.data->'customer'->'address'->>'street' as street,
      s.data->'customer'->'address'->>'complementary' as complement,
      s.data->'customer'->'address'->>'street_number' as number,
      s.data->'customer'->'address'->>'neighborhood' as neighborhood,
      s.data->'customer'->'address'->>'city' as city,
      s.data->'customer'->'address'->>'state' as state,
      s.data->'customer'->'address'->>'zipcode' as zipcode

    from common_schema.catalog_payments s
    join users u on u.common_id = s.user_id
    LEFT JOIN rewards r on r.common_id = s.reward_id
    where s.status = 'paid'
    group by s.project_id, u.name, u.public_name, u.email, s.data, r.title, r.description,
      s.created_at, u.id;
    SQL
  end
end
