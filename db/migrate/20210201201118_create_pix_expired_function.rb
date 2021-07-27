
class CreatePixExpiredFunction < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
    CREATE FUNCTION pix_expired(public.payments)
    RETURNS boolean
    LANGUAGE SQL
    STABLE
    AS $$
    SELECT $1.pix_expires_at < current_timestamp;
    $$;
    SQL
  end

  def down
    execute <<-SQL
    DROP FUNCTION pix_expired(public.payments);
    SQL
  end
end
