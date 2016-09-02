class FixWaitingPaymentFunction < ActiveRecord::Migration
  def up
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
                       WHERE extract(dow from day) not in (0,1)
                     )  <= 4
           $_$ STABLE;
    SQL
  end

end
