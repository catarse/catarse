class CreateSlipExpiresAtFunction < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE FUNCTION slip_expires_at(public.payments)
    RETURNS timestamp
    LANGUAGE SQL
    STABLE
    AS $$
    SELECT max(day) FROM (
      SELECT day
      FROM generate_series($1.created_at, $1.created_at + '1 month'::interval, '1 day') day
      WHERE extract(dow from day) not in (0,1)
      ORDER BY day
      LIMIT 2
    ) a;
    $$;
    SQL
  end

  def down
    execute <<-SQL
    DROP FUNCTION slip_expires_at(public.payments);
    SQL
  end
end
