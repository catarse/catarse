class FixesPaymentValidationFunction < ActiveRecord::Migration
  def up
    execute %Q{
CREATE OR REPLACE FUNCTION validate_project_expires_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
        v_project public.projects;
    BEGIN
    SELECT * 
        FROM public.projects p 
        JOIN public.contributions c on c.project_id = p.id
        WHERE c.id = new.contribution_id
        INTO v_project;

    IF public.is_expired(v_project) AND (COALESCE(new.created_at, now()) > v_project.expires_at) THEN
        RAISE EXCEPTION 'Project for contribution % in payment % is expired', new.contribution_id, new.id;
    END IF;
    RETURN new;
    END;
    $$;

    }
  end

  def down
    execute %Q{
CREATE OR REPLACE FUNCTION validate_project_expires_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
    IF EXISTS(SELECT true FROM public.projects p JOIN public.contributions c ON c.project_id = p.id WHERE c.id = new.contribution_id AND p.is_expired) THEN
        RAISE EXCEPTION 'Project for contribution % in payment % is expired', new.contribution_id, new.id;
    END IF;
    RETURN new;
    END;
    $$;

    }
  end
end
