class UpdateUsersFullTextIndex < ActiveRecord::Migration
  def up
    execute "SET STATEMENT_TIMEOUT to 0;"
    execute <<-SQL
      CREATE OR REPLACE FUNCTION public.update_users_full_text_index()
        RETURNS trigger
        LANGUAGE plpgsql
      AS $function$
        BEGIN
          NEW.full_text_index := to_tsvector(NEW.id::text) ||
            to_tsvector(unaccent(coalesce(NEW.name, ''))) ||
            to_tsvector(unaccent(NEW.email));
          RETURN NEW;
        END;
      $function$;

      CREATE TRIGGER update_users_full_text_index
        BEFORE INSERT OR UPDATE OF id, name, email
        ON users FOR EACH ROW
        EXECUTE PROCEDURE public.update_users_full_text_index();

      UPDATE public.users SET
        email = coalesce(email, 'contato+user' || id::text || '@catarse.me');
      ALTER TABLE public.users ALTER email SET NOT NULL;
      ALTER TABLE public.users ALTER full_text_index SET NOT NULL;
    SQL
  end

  def down
    execute <<-SQL
      DROP FUNCTION public.update_users_full_text_index() CASCADE;
      ALTER TABLE public.users ALTER email DROP NOT NULL;
      ALTER TABLE public.users ALTER full_text_index DROP NOT NULL;
    SQL
  end
end
