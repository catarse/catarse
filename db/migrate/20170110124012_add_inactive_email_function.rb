class AddInactiveEmailFunction < ActiveRecord::Migration
  def change
    execute <<-SQL
    CREATE INDEX sendgrid_events_notification_user_idx ON sendgrid_events USING btree (notification_user);

    CREATE OR REPLACE FUNCTION email_active(users) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$
      SELECT EXISTS (SELECT true from sendgrid_events 
        WHERE event IN ('open', 'click') and notification_user = $1.id and created_at > (current_timestamp - '1 month'::interval));
    $_$;
    SQL

  end
end
