class AdjustEmailActive < ActiveRecord::Migration
  def change
    execute <<-SQL
CREATE OR REPLACE FUNCTION public.email_active(users)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
AS $function$
      SELECT EXISTS (SELECT true from sendgrid_events 
        WHERE event IN ('open', 'click') and notification_user = $1.id and created_at > (current_timestamp - '1 month'::interval)) 
        OR coalesce(($1.confirmed_email_at > current_timestamp - '1 year'::interval), false);
    $function$
;
    SQL

  end
end
