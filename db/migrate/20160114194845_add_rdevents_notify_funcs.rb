class AddRdeventsNotifyFuncs < ActiveRecord::Migration
  def up
    execute <<-SQL
CREATE OR REPLACE FUNCTION public.rdevents_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_user public.users;
            v_project public.projects;
        BEGIN
            SELECT * FROM public.users WHERE id = NEW.user_id
                INTO v_user;

            SELECT * FROM public.projects WHERE id = NEW.project_id
                INTO v_project;

            PERFORM pg_notify('catartico_rdstation', json_build_object(
                'event_name', NEW.event_name,
                'email', v_user.email,
                'name', v_user.name
            )::text);

            RETURN NULL;
        END;
    $$;

CREATE TRIGGER rdevents_notifier AFTER INSERT ON public.rdevents
    FOR EACH ROW EXECUTE PROCEDURE public.rdevents_notify();

    SQL
  end

  def down
    execute <<-SQL
DROP FUNCTION public.rdevents_notify() CASCADE;
    SQL
  end
end
