class RemoveProjectAccountErrorsFromCheck < ActiveRecord::Migration
  def up
    execute %Q{
CREATE OR REPLACE FUNCTION public.project_checks_before_transfer()
 RETURNS trigger
 LANGUAGE plpgsql
 STABLE
AS $function$
        DECLARE
            v_project public.projects;
        BEGIN
            SELECT p.* FROM public.projects p WHERE p.id = new.project_id INTO v_project;

            IF NOT EXISTS (
                SELECT true FROM "1".project_transitions pt
                WHERE pt.state = 'successful' AND pt.project_id = NEW.project_id
            ) THEN
                RAISE EXCEPTION 'project need to be successful';
            END IF;

            RETURN NULL;
        END;
    $function$;

}
  end

  def down
    execute %Q{
CREATE OR REPLACE FUNCTION public.project_checks_before_transfer()
 RETURNS trigger
 LANGUAGE plpgsql
 STABLE
AS $function$
        DECLARE
            v_project public.projects;
        BEGIN
            SELECT p.* FROM public.projects p WHERE p.id = new.project_id INTO v_project;

            IF NOT EXISTS (
                SELECT true FROM "1".project_transitions pt
                WHERE pt.state = 'successful' AND pt.project_id = NEW.project_id
            ) THEN
                RAISE EXCEPTION 'project need to be successful';
            END IF;

            IF public.has_error_on_project_account(new.project_id) THEN
                RAISE EXCEPTION 'project account have unsolved error';
            END IF;

            RETURN NULL;
        END;
    $function$;

}
  end
end
