class FixesProjectAccountErrorsTriggers < ActiveRecord::Migration
  def up
    add_column :project_account_errors, :solved_at, :datetime
    change_column_default :project_account_errors, :created_at, 'now()'
    execute <<-SQL
GRANT UPDATE ON public.project_account_errors TO admin;

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
    $function$
;

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
    $function$
;
    SQL
  end
end
