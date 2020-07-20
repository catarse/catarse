class CreationAndPushToOnlineRdeventsOnSolidarityProjects < ActiveRecord::Migration
  def up
    execute <<-SQL

      CREATE OR REPLACE FUNCTION public.is_solidarity_project(project_id integer)
        RETURNS boolean
        LANGUAGE sql
      AS $$
        select exists(
          select integration.project_id
          from public.project_integrations integration 
          where integration.project_id = $1 and integration.name = 'SOLIDARITY_SERVICE_FEE'
        );
      $$
      ;

      CREATE OR REPLACE FUNCTION public.flexible_project_rdevents_dispatcher()
        RETURNS trigger
        LANGUAGE plpgsql
      AS $function$
        DECLARE
          v_user_id integer;
          v_project_id integer;
          v_enabled_events text[];
          v_mode_concat text;
        BEGIN
          v_enabled_events =  ARRAY['online',  'waiting_funds', 'successful', 'failed'];

          SELECT project_id FROM flexible_projects WHERE id = NEW.flexible_project_id
              INTO v_project_id;
          SELECT user_id FROM projects WHERE id = v_project_id
              INTO v_user_id;

          v_mode_concat = (CASE WHEN is_solidarity_project(NEW.flexible_project_id) THEN 'solidaria_project_'
                                ELSE 'flex_project_' END);

          IF NEW.to_state = ANY(v_enabled_events) THEN
              INSERT INTO public.rdevents (user_id, project_id, event_name, created_at)
                  VALUES (v_user_id, v_project_id, v_mode_concat||NEW.to_state, now());
          END IF;

          RETURN NULL;
        END;
      $function$
      ;

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

            v_mode_concat = (CASE WHEN is_solidarity_project(NEW.project_id) THEN 'solidaria_project_'
                                  WHEN v_project.mode = 'flex' THEN 'flex_project_' 
                                  WHEN v_project.mode = 'sub' THEN 'sub_project_' 
                                  ELSE 'project_' END);

            IF NEW.to_state = ANY(v_enabled_events) THEN
                INSERT INTO public.rdevents (user_id, project_id, event_name, created_at)
                    VALUES (v_project.user_id, NEW.project_id, v_mode_concat||NEW.to_state, now());
            END IF;

            RETURN NULL;
        END;
      $function$
      ;

      drop trigger project_received_conversion on projects;

      drop function project_received_conversion;
    
    SQL
  end

  def down
    execute <<-SQL

      DROP FUNCTION public.is_solidarity_project(project_id integer);

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
      $function$
      ;
      
      CREATE OR REPLACE FUNCTION public.flexible_project_rdevents_dispatcher()
        RETURNS trigger
        LANGUAGE plpgsql
      AS $function$
        DECLARE
          v_user_id integer;
          v_project_id integer;
          v_enabled_events text[];
        BEGIN
          v_enabled_events =  ARRAY['online',  'waiting_funds', 'successful', 'failed'];

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
      $function$
      ;
      ---
      
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
      ---     

    SQL
  end

end
