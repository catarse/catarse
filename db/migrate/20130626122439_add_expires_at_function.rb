class AddExpiresAtFunction < ActiveRecord::Migration
  def up
    execute "
    CREATE FUNCTION expires_at(projects) RETURNS timestamp AS $$
     SELECT (($1.online_date + ($1.online_days || ' days')::interval)::date::text || ' 23:59:59')::timestamp
    $$ LANGUAGE SQL;
    "
  end

  def down
  end
end
