class AdjustProjectTransitionsRdEventsToUseSubscription < ActiveRecord::Migration[4.2]
  def up
    execute %Q{
CREATE OR REPLACE FUNCTION public.project_rdevents_dispatcher()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
        DECLARE
            v_enabled_events text[];
            v_project public.projects;
            v_mode_concat text;
        BEGIN
            v_enabled_events =  ARRAY['in_analysis', 'approved', 'online',  'waiting_funds', 'successful', 'failed'];

            SELECT * FROM projects WHERE id = NEW.project_id
                INTO v_project;

            v_mode_concat = (CASE WHEN v_project.mode = 'flex' THEN 'flex_project_'
                                  WHEN v_project.mode = 'sub' THEN 'sub_project_'
                                  ELSE 'project_' END);

            IF NEW.to_state = ANY(v_enabled_events) THEN
                INSERT INTO public.rdevents (user_id, project_id, event_name, created_at)
                    VALUES (v_project.user_id, NEW.project_id, v_mode_concat||NEW.to_state, now());
            END IF;

            RETURN NULL;
        END;
    $function$;

CREATE OR REPLACE FUNCTION public.project_received_conversion()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
        DECLARE
            _rd_event_name text;
        BEGIN
            _rd_event_name := (CASE NEW.mode
                                WHEN 'sub' THEN 'sub_project_draft'
                                ELSE 'project_draft' END);

            INSERT INTO public.rdevents (user_id, project_id, event_name)
                VALUES (NEW.user_id, NEW.id, _rd_event_name);
            RETURN NULL;
        END;
    $function$
;
}
  end

  def down
    execute %Q{
CREATE OR REPLACE FUNCTION public.project_rdevents_dispatcher()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
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
    $function$;

CREATE OR REPLACE FUNCTION public.project_received_conversion()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
        BEGIN
            INSERT INTO public.rdevents (user_id, project_id, event_name)
                VALUES (NEW.user_id, NEW.id, 'project_draft');
            RETURN NULL;
        END;
    $function$
;
}
  end
end
