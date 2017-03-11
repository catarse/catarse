class FixWaitingPayment < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION public.waiting_payment(payments) RETURNS boolean
          LANGUAGE sql
          AS $_$
            SELECT
                     $1.state = 'pending'
                     AND
                     (CASE WHEN (($1.gateway_data::json->>'boleto_expiration_date')::timestamp with time zone) is not null THEN
                      ($1.gateway_data::json->>'boleto_expiration_date')::timestamp with time zone > current_timestamp
                     ELSE
                     ((
                       SELECT count(1) AS total_of_days
                       FROM generate_series($1.created_at::date, current_date, '1 day') day
                       WHERE extract(dow from day) not in (0,6)
                     ))  <= 4
                     END
                     )
           $_$ STABLE;
    SQL
  end
  def down
    execute <<-SQL
      CREATE OR REPLACE FUNCTION public.waiting_payment(payments) RETURNS boolean
          LANGUAGE sql
          AS $_$
            SELECT
                     $1.state = 'pending'
                     AND
                     (
                       SELECT count(1) AS total_of_days
                       FROM generate_series($1.created_at::date, current_date, '1 day') day
                       WHERE extract(dow from day) not in (0,6)
                     )  <= 4
           $_$ STABLE;
    SQL
  end


end
