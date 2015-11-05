class CreateSentValidationConstraint < ActiveRecord::Migration
  def up
    execute <<-SQL
UPDATE project_accounts SET agency = lpad(agency, 4, '0') WHERE length(agency) < 4;
ALTER TABLE project_accounts ADD CHECK (length(agency) >= 4);

CREATE FUNCTION public.assert_not_null(field anyelement, field_name text)
RETURNS void
LANGUAGE plpgsql
AS $fn$
BEGIN
  IF field IS NULL THEN
    RAISE EXCEPTION $$% can't be null$$, field_name;
  END IF;
  RETURN;
END;
$fn$;

CREATE OR REPLACE FUNCTION public.sent_validation()
RETURNS trigger
LANGUAGE plpgsql
AS $fn$
BEGIN
  IF state_order(new) >= 'sent'::project_state_order THEN
    PERFORM assert_not_null(new.about_html, 'about_html');
    PERFORM assert_not_null(new.headline, 'headline');
    IF new.video_thumbnail IS NULL AND new.uploaded_image IS NULL THEN
      RAISE EXCEPTION $$video_thumbnail and uploaded_image can't both be null$$;
    END IF;
    IF EXISTS (SELECT true FROM users u WHERE u.id = new.user_id AND u.name IS NULL) THEN
      RAISE EXCEPTION $$name of project owner can't be null$$;
    END IF;
  END IF;
  RETURN null;
END;
$fn$;

CREATE CONSTRAINT TRIGGER sent_validation
AFTER INSERT OR UPDATE ON public.projects
FOR EACH ROW EXECUTE PROCEDURE public.sent_validation();
    SQL
  end

  def down
    execute <<-SQL
DROP FUNCTION public.sent_validation() CASCADE;
    SQL
  end
end
