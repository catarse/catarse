class AdjustSentValidationToUserPublicName < ActiveRecord::Migration
  def up
    execute %Q{
CREATE OR REPLACE FUNCTION public.sent_validation()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
    BEGIN
      IF state_order(new) >= 'sent'::project_state_order THEN
        PERFORM assert_not_null(new.about_html, 'about_html');
        PERFORM assert_not_null(new.headline, 'headline');
        IF EXISTS (SELECT true FROM users u WHERE u.id = new.user_id AND u.public_name IS NULL) THEN
          RAISE EXCEPTION $$name of project owner can't be null$$;
        END IF;
      END IF;
      RETURN null;
    END;
    $function$;
}
  end

  def down
    execute %Q{
CREATE OR REPLACE FUNCTION public.sent_validation()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
    BEGIN
      IF state_order(new) >= 'sent'::project_state_order THEN
        PERFORM assert_not_null(new.about_html, 'about_html');
        PERFORM assert_not_null(new.headline, 'headline');
        IF EXISTS (SELECT true FROM users u WHERE u.id = new.user_id AND u.name IS NULL) THEN
          RAISE EXCEPTION $$name of project owner can't be null$$;
        END IF;
      END IF;
      RETURN null;
    END;
    $function$;
}
  end
end
