class ReplaceExpiresAtToIncludeTimezone < ActiveRecord::Migration
  def up
    execute "
    DROP FUNCTION expires_at(projects);
    CREATE OR REPLACE FUNCTION expires_at(projects) RETURNS timestamptz AS $$
     SELECT (($1.online_date + ($1.online_days || ' days')::interval)::date::text || ' 23:59:59')::timestamp AT TIME ZONE coalesce((SELECT value FROM configurations WHERE name = 'timezone'), 'America/Sao_Paulo')
    $$ LANGUAGE SQL;
    "
  end

  def down
    execute "
    CREATE OR REPLACE FUNCTION expires_at(projects) RETURNS timestamp AS $$
     SELECT (($1.online_date + ($1.online_days || ' days')::interval)::date::text || ' 23:59:59')::timestamp
    $$ LANGUAGE SQL;
    "
  end
end
