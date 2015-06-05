class CreateUserAndPostgrestAuthSync < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE EXTENSION pgcrypto;
    CREATE OR REPLACE FUNCTION postgrest.create_api_user() RETURNS TRIGGER AS $$
    BEGIN
      INSERT INTO postgrest.auth (id, rolname, pass) VALUES (new.email, CASE WHEN new.admin THEN 'admin' ELSE 'web_user' END, crypt(new.authentication_token, gen_salt('bf')));
      return new;
    END;
    $$ LANGUAGE plpgsql;

    CREATE OR REPLACE FUNCTION postgrest.update_api_user() RETURNS TRIGGER AS $$
    BEGIN
      UPDATE postgrest.auth SET 
        id = new.email,
        rolname = CASE WHEN new.admin THEN 'admin' ELSE 'web_user' END, 
        pass = CASE WHEN new.authentication_token <> old.authentication_token THEN crypt(new.authentication_token, gen_salt('bf')) ELSE pass END
      WHERE id = old.email;
      return new;
    END;
    $$ LANGUAGE plpgsql;

    CREATE OR REPLACE FUNCTION postgrest.delete_api_user() RETURNS TRIGGER AS $$
    BEGIN
      DELETE FROM postgrest.auth WHERE id = old.email;
      return old;
    END;
    $$ LANGUAGE plpgsql;

    CREATE TRIGGER create_api_user AFTER INSERT
    ON public.users
    FOR EACH ROW
    EXECUTE PROCEDURE postgrest.create_api_user();

    CREATE TRIGGER update_api_user AFTER UPDATE OF email, admin, authentication_token 
    ON public.users
    FOR EACH ROW
    EXECUTE PROCEDURE postgrest.update_api_user();

    CREATE TRIGGER delete_api_user AFTER DELETE
    ON public.users
    FOR EACH ROW
    EXECUTE PROCEDURE postgrest.delete_api_user();
    SQL
  end

  def down
    execute <<-SQL
    DROP FUNCTION postgrest.create_api_user() CASCADE;
    DROP FUNCTION postgrest.update_api_user() CASCADE;
    DROP FUNCTION postgrest.delete_api_user() CASCADE;
    DROP EXTENSION pgcrypto;
    SQL
  end
end
