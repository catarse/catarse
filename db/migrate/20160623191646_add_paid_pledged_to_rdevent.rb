class AddPaidPledgedToRdevent < ActiveRecord::Migration
  def up
    execute %{
CREATE OR REPLACE FUNCTION public.rdevents_notify()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
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
                'name', v_user.name,
                'status', (case when new.event_name ~* 'successful' then 'won' else null end),
                'value', (case when new.event_name ~* 'successful' then public.total_catarse_fee_without_gateway_fee(v_project) else null end)
            )::text);

            RETURN NULL;
        END;
    $function$
;
    }
  end

  def down
    execute %{
CREATE OR REPLACE FUNCTION public.rdevents_notify()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
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
    $function$
;
    }
  end
end
