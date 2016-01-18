class AddConversionFuncs < ActiveRecord::Migration
  def up
    change_column_null :rdevents, :user_id, false
    change_column_default :rdevents, :created_at, 'now()'

    execute <<-SQL
CREATE OR REPLACE FUNCTION public.project_received_conversion() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        BEGIN
            INSERT INTO public.rdevents (user_id, project_id, event_name)
                VALUES (NEW.user_id, NEW.id, 'project_draft');
            RETURN NULL;
        END;
    $$;

CREATE TRIGGER project_received_conversion AFTER INSERT ON public.projects
    FOR EACH ROW EXECUTE PROCEDURE public.project_received_conversion();

CREATE OR REPLACE FUNCTION public.project_rdevents_dispatcher() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_user_id integer;
            v_enabled_events text[];
        BEGIN
            v_enabled_events =  ARRAY['in_analysis', 'approved', 'online',  'waiting_funds', 'successful', 'failed'];

            SELECT user_id FROM projects WHERE id = NEW.project_id
                INTO v_user_id;

            IF NEW.to_state = ANY(v_enabled_events) THEN
                INSERT INTO public.rdevents (user_id, project_id, event_name)
                    VALUES (v_user_id, NEW.project_id, 'project_'||NEW.to_state);
            END IF;

            RETURN NULL;
        END;
    $$;

CREATE TRIGGER project_rdevents_dispatcher AFTER INSERT ON public.project_transitions
    FOR EACH ROW EXECUTE PROCEDURE public.project_rdevents_dispatcher();

CREATE OR REPLACE FUNCTION public.flexible_project_rdevents_dispatcher() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_user_id integer;
            v_project_id integer;
            v_enabled_events text[];
        BEGIN
            v_enabled_events =  ARRAY['online',  'waiting_funds', 'successful'];

            SELECT project_id FROM flexible_projects WHERE id = NEW.flexible_project_id
                INTO v_project_id;
            SELECT user_id FROM projects WHERE id = v_project_id
                INTO v_user_id;

            IF NEW.to_state = ANY(v_enabled_events) THEN
                INSERT INTO public.rdevents (user_id, project_id, event_name)
                    VALUES (v_user_id, v_project_id, 'flex_project_'||NEW.to_state);
            END IF;

            RETURN NULL;
        END;
    $$;
CREATE TRIGGER flexible_project_rdevents_dispatcher AFTER INSERT ON public.flexible_project_transitions
    FOR EACH ROW EXECUTE PROCEDURE public.flexible_project_rdevents_dispatcher();

    SQL
  end

  def down
    change_column_null :rdevents, :user_id, true
    change_column_default :rdevents, :created_at, nil

    execute <<-SQL
DROP FUNCTION public.project_received_conversion() CASCADE;
DROP FUNCTION public.project_rdevents_dispatcher() CASCADE;
DROP FUNCTION public.flexible_project_rdevents_dispatcher() CASCADE;
    SQL
  end
end
