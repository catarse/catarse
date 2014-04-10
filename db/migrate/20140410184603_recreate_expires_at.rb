class RecreateExpiresAt < ActiveRecord::Migration
  def change
    execute "
    CREATE OR REPLACE FUNCTION expires_at(projects) RETURNS timestamptz AS $$
     SELECT ((((($1.online_date AT TIME ZONE coalesce((SELECT value FROM settings WHERE name = 'timezone'), 'America/Sao_Paulo') + ($1.online_days || ' days')::interval)  )::date::text || ' 23:59:59')::timestamp AT TIME ZONE coalesce((SELECT value FROM settings WHERE name = 'timezone'), 'America/Sao_Paulo'))::timestamptz )               
    $$ LANGUAGE SQL;
    "
  end
end
