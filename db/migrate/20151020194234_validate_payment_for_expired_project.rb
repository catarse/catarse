class ValidatePaymentForExpiredProject < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE FUNCTION public.validate_project_expires_at()
    RETURNS trigger
    LANGUAGE plpgsql AS $$
    BEGIN
    IF EXISTS(SELECT true FROM public.projects p JOIN public.contributions c ON c.project_id = p.id WHERE c.id = new.contribution_id AND p.is_expired) THEN
        RAISE EXCEPTION 'Project for contribution % in payment % is expired', new.contribution_id, new.id;
    END IF;
    RETURN new;
    END;
    $$;

    CREATE TRIGGER validate_project_expires_at
    BEFORE INSERT OR UPDATE OF contribution_id
    ON public.payments
    FOR EACH ROW EXECUTE PROCEDURE public.validate_project_expires_at();
    SQL
  end

  def down
    execute <<-SQL
    DROP FUNCTION public.validate_project_expires_at() CASCADE;
    SQL
  end
end
