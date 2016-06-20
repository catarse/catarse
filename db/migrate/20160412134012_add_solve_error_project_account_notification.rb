class AddSolveErrorProjectAccountNotification < ActiveRecord::Migration
  def up
    execute <<-SQL
CREATE OR REPLACE FUNCTION solve_error_reason() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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

            IF current_user <> 'admin' THEN
                RAISE EXCEPTION 'insufficient privileges to delete on project_errors_accounts';
            END IF;

            UPDATE public.project_account_errors
                SET solved=true,
                    solved_at=now()
                WHERE project_account_id = v_project_acc.id AND not solved;

            INSERT INTO public.project_notifications(user_id, project_id, from_email, from_name, template_name, locale, created_at) VALUES
                (v_project.user_id, v_project.id, settings('email_contact'), settings('company_name'), 'project_account_error_solved', 'pt', now());

            SELECT * FROM "1".project_account_errors
                WHERE project_account_id = v_project_acc.id
                AND solved ORDER BY created_at DESC LIMIT 1 INTO v_error;

            RETURN v_error;
        END;
    $$;
    SQL
  end

  def down
    execute <<-SQL
CREATE OR REPLACE FUNCTION solve_error_reason() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
    $$;
    SQL
  end
end
