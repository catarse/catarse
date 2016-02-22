class AddProjectAccountErrorsEndpoint < ActiveRecord::Migration
  def up
    execute <<-SQL
CREATE VIEW "1".project_account_errors AS
    SELECT
        pa.project_id,
        pae.project_account_id,
        pae.reason,
        pae.solved,
        public.zone_timestamp(pae.created_at) as created_at
    FROM public.project_account_errors pae
    JOIN public.project_accounts pa ON pa.id = pae.project_account_id;

CREATE OR REPLACE FUNCTION add_error_reason() RETURNS trigger
    STABLE LANGUAGE plpgsql
    AS $$
        DECLARE
            v_error "1".project_account_errors;
            v_project public.projects;
            v_project_acc_id integer;
        BEGIN
            SELECT * FROM "1".project_account_errors
                WHERE project_id = NEW.project_id AND NOT solved
                INTO v_error;

            SELECT id FROM public.project_accounts
                WHERE project_id = NEW.project_id LIMIT 1
                INTO v_project_acc_id;

            SELECT * FROM public.projects
                WHERE id = NEW.project_id INTO v_project;

            IF v_error IS NOT NULL THEN
                RAISE EXCEPTION 'project account already have an error unsolved';
            END IF;

            IF NOT public.is_owner_or_admin(v_project.user_id) THEN
                RAISE EXCEPTION 'insufficient privileges to insert on project_errors_accounts';
            END IF;

            INSERT INTO public.project_account_errors
                (project_account_id, reason, solved) VALUES
                (v_project_acc_id, NEW.reason, false);

            SELECT * FROM "1".project_account_errors WHERE project_id = NEW.project_id INTO v_error;

            RETURN v_error;
        END;
    $$;

CREATE TRIGGER add_error_reason
    INSTEAD OF INSERT ON "1".project_account_errors
    FOR EACH ROW EXECUTE PROCEDURE public.add_error_reason();

CREATE OR REPLACE FUNCTION solve_error_reason() RETURNS trigger
    STABLE LANGUAGE plpgsql
    AS $$
        DECLARE
            v_error "1".project_account_errors;
            v_project public.projects;
            v_project_acc_id integer;
        BEGIN
            SELECT id FROM public.project_accounts
                WHERE project_id = NEW.project_id LIMIT 1
                INTO v_project_acc_id;

            SELECT * FROM public.projects
                WHERE id = NEW.project_id INTO v_project;

            IF NOT public.is_owner_or_admin(v_project.user_id) THEN
                RAISE EXCEPTION 'insufficient privileges to insert on project_errors_accounts';
            END IF;

            UPDATE public.project_account_errors
                SET solved=true
                WHERE project_id = v_project.id;

            SELECT * FROM "1".project_account_errors WHERE project_id = NEW.project_id INTO v_error;

            RETURN v_error;
        END;
    $$;

CREATE TRIGGER solve_error_reason
    INSTEAD OF DELETE ON "1".project_account_errors
    FOR EACH ROW EXECUTE PROCEDURE public.solve_error_reason();

GRANT SELECT, INSERT ON "1".project_account_errors TO admin, web_user;
GRANT DELETE ON "1".project_account_errors TO admin;

GRANT SELECT, INSERT ON public.project_account_errors TO admin, web_user;
GRANT DELETE ON public.project_account_errors TO admin, web_user;

GRANT USAGE ON SEQUENCE project_account_errors_id_seq TO admin, web_user;
    SQL
  end

  def down
    execute <<-SQL
DROP VIEW "1".project_account_errors CASCADE;
    SQL
  end
end
