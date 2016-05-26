class AdjustRdDispacher < ActiveRecord::Migration
  def up
    execute %{
CREATE OR REPLACE FUNCTION project_rdevents_dispatcher() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_enabled_events text[];
            v_project public.projects;
            v_mode_concat text;
        BEGIN
            v_enabled_events =  ARRAY['in_analysis', 'approved', 'online',  'waiting_funds', 'successful', 'failed'];

            SELECT * FROM projects WHERE id = NEW.project_id
                INTO v_project;

            v_mode_concat = (CASE WHEN v_project.mode = 'flex' THEN 'flex_project_' ELSE 'project_' END);

            IF NEW.to_state = ANY(v_enabled_events) THEN
                INSERT INTO public.rdevents (user_id, project_id, event_name, created_at)
                    VALUES (v_project.user_id, NEW.project_id, v_mode_concat||NEW.to_state, now());
            END IF;

            RETURN NULL;
        END;
    $$;
    }
  end

  def down
    execute %{
CREATE OR REPLACE FUNCTION project_rdevents_dispatcher() RETURNS trigger
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
                INSERT INTO public.rdevents (user_id, project_id, event_name, created_at)
                    VALUES (v_user_id, NEW.project_id, 'project_'||NEW.to_state, now());
            END IF;

            RETURN NULL;
        END;
    $$;
    }
  end
end
