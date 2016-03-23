class AddSystemNotificationsDispatcher < ActiveRecord::Migration
  def up
    execute <<-SQL
CREATE OR REPLACE FUNCTION system_notification_dispatcher() RETURNS trigger
    LANGUAGE plpgsql
    STABLE
    AS $$
        BEGIN
            PERFORM pg_notify('system_notifications', json_build_object(
                'relation', TG_RELNAME,
                'table', TG_TABLE_NAME,
                'id', NEW.id
            )::text);

            RETURN NULL;
        END;
    $$;

CREATE TRIGGER system_notification_dispatcher AFTER INSERT ON public.contribution_notifications  FOR EACH ROW EXECUTE PROCEDURE public.system_notification_dispatcher();

CREATE TRIGGER system_notification_dispatcher AFTER INSERT ON public.category_notifications FOR EACH ROW EXECUTE PROCEDURE public.system_notification_dispatcher();

CREATE TRIGGER system_notification_dispatcher AFTER INSERT ON public.donation_notifications FOR EACH ROW EXECUTE PROCEDURE public.system_notification_dispatcher();

CREATE TRIGGER system_notification_dispatcher AFTER INSERT ON public.project_notifications FOR EACH ROW EXECUTE PROCEDURE public.system_notification_dispatcher();

CREATE TRIGGER system_notification_dispatcher AFTER INSERT ON public.project_post_notifications FOR EACH ROW EXECUTE PROCEDURE public.system_notification_dispatcher();

CREATE TRIGGER system_notification_dispatcher AFTER INSERT ON public.user_notifications FOR EACH ROW EXECUTE PROCEDURE public.system_notification_dispatcher();

CREATE TRIGGER system_notification_dispatcher AFTER INSERT ON public.user_transfer_notifications FOR EACH ROW EXECUTE PROCEDURE public.system_notification_dispatcher();
    SQL
  end

  def down
    execute <<-SQL
DROP FUNCTION system_notification_dispatcher() CASCADE;
    SQL
  end
end
