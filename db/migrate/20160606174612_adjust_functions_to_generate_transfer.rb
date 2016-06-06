class AdjustFunctionsToGenerateTransfer < ActiveRecord::Migration
  def up
    execute %{
CREATE OR REPLACE FUNCTION project_checks_before_transfer() RETURNS trigger
    LANGUAGE plpgsql STABLE
    AS $$
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
    $$;

    }
  end

  def down
    execute %{
CREATE OR REPLACE FUNCTION project_checks_before_transfer() RETURNS trigger
    LANGUAGE plpgsql STABLE
    AS $$
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

            IF v_project.expires_at::date < '2016-06-06' THEN
                RAISE EXCEPTION 'balance transfer not enabled for project';
            END IF;

            IF public.has_error_on_project_account(new.project_id) THEN
                RAISE EXCEPTION 'project account have unsolved error';
            END IF;

            RETURN NULL;
        END;
    $$;
    }
  end
end
