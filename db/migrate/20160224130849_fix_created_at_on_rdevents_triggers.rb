class FixCreatedAtOnRdeventsTriggers < ActiveRecord::Migration
  def up
    execute <<-SQL
ALTER TABLE rdevents
    ALTER COLUMN created_at SET DEFAULT now();

CREATE OR REPLACE FUNCTION flexible_project_rdevents_dispatcher() RETURNS trigger
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
                INSERT INTO public.rdevents (user_id, project_id, event_name, created_at)
                    VALUES (v_user_id, v_project_id, 'flex_project_'||NEW.to_state, now());
            END IF;

            RETURN NULL;
        END;
    $$;

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

    SQL
  end

  def down
    execute <<-SQL
CREATE OR REPLACE FUNCTION flexible_project_rdevents_dispatcher() RETURNS trigger
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
                INSERT INTO public.rdevents (user_id, project_id, event_name)
                    VALUES (v_user_id, NEW.project_id, 'project_'||NEW.to_state);
            END IF;

            RETURN NULL;
        END;
    $$;
    SQL
  end
end
