class CreateCanDeleteFunction < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE OR REPLACE FUNCTION public.can_delete(payments)
     RETURNS boolean
     LANGUAGE sql
    AS $function$
            SELECT
              $1.state = 'pending' 
              AND
              (
                SELECT count(1) AS total_of_days
                FROM generate_series($1.created_at::date, current_date, '1 day') day
                WHERE extract(dow from day) not in (0,1)
              )  >= 5
          $function$
    SQL
  end

  def down
    execute "DROP FUNCTION can_delete(contributions);"
  end
end
