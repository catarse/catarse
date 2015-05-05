class MigrateExpiresAt < ActiveRecord::Migration
  def change
    execute "UPDATE projects SET expires_at = 
 (((
  (online_date AT TIME ZONE coalesce((SELECT value FROM settings WHERE name = 'timezone'), 'America/Sao_Paulo')
   + (online_days || ' days')::interval)
)::date::text || ' 23:59:59')::timestamp AT TIME ZONE coalesce((SELECT value FROM settings WHERE name = 'timezone'), 'America/Sao_Paulo'))::timestamptz;"
  end
end
