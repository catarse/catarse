class AddProjectAccountErrorsToApi < ActiveRecord::Migration
    def up
    execute <<-SQL
CREATE VIEW "1".project_account_errors AS
    SELECT
        pa.project_id,
        pae.project_account_id,
        pae.reason,
        pae.solved,
        public.zone_timestamp(pae.solved_at),
        public.zone_timestamp(pae.created_at) as created_at
    FROM public.project_account_errors pae
        JOIN public.project_accounts pa ON pa.id = pae.project_account_id
        JOIN public.projects p ON p.id = pa.project_id
    WHERE public.is_owner_or_admin(p.user_id);

CREATE OR REPLACE FUNCTION public.add_error_reason()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
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

            IF v_error.project_id IS NOT NULL THEN
                RAISE EXCEPTION 'project account already have an error unsolved';
            END IF;

            IF NOT public.is_owner_or_admin(v_project.user_id) THEN
                RAISE EXCEPTION 'insufficient privileges to insert on project_errors_accounts';
            END IF;

            INSERT INTO public.project_account_errors
                (project_account_id, reason, solved, created_at) VALUES
                (v_project_acc_id, NEW.reason, false, now());

            SELECT * FROM "1".project_account_errors WHERE project_id = NEW.project_id AND NOT solved INTO v_error;

            RETURN v_error;
        END;
    $function$;

CREATE OR REPLACE FUNCTION public.solve_error_reason()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
        DECLARE
            v_error "1".project_account_errors;
            v_project public.projects;
            v_project_acc public.project_accounts;
        BEGIN
            SELECT * FROM public.project_accounts
                WHERE id = OLD.project_account_id INTO v_project_acc;

            IF v_project_acc.project_id IS NULL THEN
                RAISE EXCEPTION 'invalid project_account';
            END IF;

            SELECT * FROM public.projects
                WHERE id = v_project_acc.project_id INTO v_project;

            IF NOT public.is_owner_or_admin(v_project.user_id) THEN
                RAISE EXCEPTION 'insufficient privileges to delete on project_errors_accounts';
            END IF;

            UPDATE public.project_account_errors
                SET solved=true,
                    solved_at=now()
                WHERE project_account_id = v_project_acc.id AND not solved;

            SELECT * FROM "1".project_account_errors 
                WHERE project_account_id = v_project_acc.id
                AND solved ORDER BY created_at DESC LIMIT 1 INTO v_error;

            RETURN v_error;
        END;
    $function$;

CREATE TRIGGER add_error_reason
    INSTEAD OF INSERT ON "1".project_account_errors
    FOR EACH ROW EXECUTE PROCEDURE public.add_error_reason();

CREATE TRIGGER solve_error_reason
    INSTEAD OF DELETE ON "1".project_account_errors
    FOR EACH ROW EXECUTE PROCEDURE public.solve_error_reason();

GRANT SELECT, INSERT ON "1".project_account_errors TO admin, web_user;
GRANT DELETE ON "1".project_account_errors TO admin;

GRANT SELECT, INSERT ON public.project_account_errors TO admin, web_user;
GRANT UPDATE ON public.project_account_errors TO admin;
GRANT DELETE ON public.project_account_errors TO admin, web_user;

GRANT USAGE ON SEQUENCE project_account_errors_id_seq TO admin, web_user;
    SQL
    end

    def down
      execute <<-SQL
DROP VIEW "1".project_account_errors;
DROP FUNCTION public.add_error_reason();
DROP FUNCTION public.solve_error_reason();

REVOKE SELECT, UPDATE, INSERT ON public.project_account_errors FROM admin, web_user;
REVOKE USAGE ON SEQUENCE project_account_errors_id_seq FROM admin, web_user;
      SQL
    end
end
