class CreateSlipExpiredFunction < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE FUNCTION slip_expired(public.payments)
    RETURNS boolean
    LANGUAGE SQL
    STABLE
    AS $$
    SELECT $1.slip_expires_at < current_timestamp;
    $$;
    SQL
  end

  def down
    execute <<-SQL
    DROP FUNCTION slip_expired(public.payments);
    SQL
  end
end
