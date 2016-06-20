class AdjustProjectCheckTrigger < ActiveRecord::Migration
  def up
    execute %Q{
CREATE OR REPLACE FUNCTION public.has_error_on_project_account(pid integer) RETURNS boolean
    LANGUAGE sql STABLE
    AS $$
        SELECT COALESCE((
            SELECT TRUE FROM public.project_account_errors pae
            JOIN project_accounts pa on pa.id = pae.project_account_id
            WHERE pa.project_id = pid AND NOT pae.solved LIMIT 1
        ), false);
    $$;

CREATE OR REPLACE FUNCTION public.project_checks_before_transfer() RETURNS trigger
    LANGUAGE plpgsql STABLE
    AS $$
        BEGIN
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
    execute %Q{
CREATE OR REPLACE FUNCTION project_checks_before_transfer() RETURNS trigger
    LANGUAGE plpgsql STABLE
    AS $$
        BEGIN
            IF NOT EXISTS (
                SELECT true FROM "1".project_transitions pt
                WHERE pt.state = 'successful' AND pt.project_id = NEW.project_id
            ) THEN
                RAISE EXCEPTION 'project need to be successful';
            END IF;

            IF EXISTS (
                SELECT true FROM "1".project_accounts pa
                WHERE pa.error_reason IS NOT NULL AND pa.project_id = NEW.project_id
            ) THEN
                RAISE EXCEPTION 'project account have unsolved error';
            END IF;

            RETURN NULL;
        END;
    $$;
DROP FUNCTION public.has_error_on_project_account(integer);
    }
  end
end
