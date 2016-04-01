class DropImageValidation < ActiveRecord::Migration
  def change
    execute <<-SQL
    CREATE OR REPLACE FUNCTION sent_validation() RETURNS trigger
        LANGUAGE plpgsql
        AS $_$
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
    $_$;
    SQL
  end
end
