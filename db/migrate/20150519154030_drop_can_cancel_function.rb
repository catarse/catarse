class DropCanCancelFunction < ActiveRecord::Migration
  def up
    execute "DROP FUNCTION can_cancel(contributions);"
  end

  def down
    execute <<-SQL
    CREATE OR REPLACE FUNCTION public.can_cancel(contributions)
     RETURNS boolean
     LANGUAGE sql
    AS $function$
            select
              $1.state = 'waiting_confirmation' and
              (
                ((
                  select count(1) as total_of_days
                  from generate_series($1.created_at::date, (current_timestamp AT TIME ZONE coalesce((SELECT value FROM settings WHERE name = 'timezone'), 'America/Sao_Paulo'))::date, '1 day') day
                  WHERE extract(dow from day) not in (0,1)
                )  > 4)
                OR
                (
                  lower($1.payment_choice) = lower('DebitoBancario')
                  AND
                    (
                      select count(1) as total_of_days
                      from generate_series($1.created_at::date, (current_timestamp AT TIME ZONE coalesce((SELECT value FROM settings WHERE name = 'timezone'), 'America/Sao_Paulo'))::date, '1 day') day
                      WHERE extract(dow from day) not in (0,1)
                    )  > 1)
              )
          $function$
    SQL
  end
end
