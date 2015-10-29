class RemovePostgrestAuthTable < ActiveRecord::Migration
  def up
    execute <<-SQL
    DROP SCHEMA postgrest CASCADE;
    
    SQL
  end

  def down
    execute <<-SQL
      CREATE SCHEMA postgrest;

      CREATE TABLE postgrest.auth (
        id text NOT NULL,
        rolname name NOT NULL,
        pass character(60) NOT NULL,
        CONSTRAINT auth_pkey PRIMARY KEY (id)
      ) WITH ( OIDS=FALSE );

      CREATE FUNCTION postgrest.check_role_exists() RETURNS trigger
          LANGUAGE plpgsql
          AS $$
      begin 
      if not exists (select 1 from pg_roles as r where r.rolname = new.rolname) then
         raise foreign_key_violation using message = 'Cannot create user with unknown role: ' || new.rolname;
         return null;
       end if;
       return new;
      end
      $$;

      CREATE CONSTRAINT TRIGGER ensure_auth_role_exists
        AFTER INSERT OR UPDATE
        ON postgrest.auth
        FOR EACH ROW
        EXECUTE PROCEDURE postgrest.check_role_exists();

    CREATE OR REPLACE FUNCTION postgrest.create_api_user() RETURNS TRIGGER AS $$
    BEGIN
      INSERT INTO postgrest.auth (id, rolname, pass) VALUES (new.id::text, CASE WHEN new.admin THEN 'admin' ELSE 'web_user' END, public.crypt(new.authentication_token, public.gen_salt('bf')));
      return new;
    END;
    $$ LANGUAGE plpgsql;

    CREATE OR REPLACE FUNCTION postgrest.update_api_user() RETURNS TRIGGER AS $$
    BEGIN
      UPDATE postgrest.auth SET 
        id = new.id::text,
        rolname = CASE WHEN new.admin THEN 'admin' ELSE 'web_user' END, 
        pass = CASE WHEN new.authentication_token <> old.authentication_token THEN public.crypt(new.authentication_token, public.gen_salt('bf')) ELSE pass END
      WHERE id = old.id::text;
      return new;
    END;
    $$ LANGUAGE plpgsql;

    CREATE OR REPLACE FUNCTION postgrest.delete_api_user() RETURNS TRIGGER AS $$
    BEGIN
      DELETE FROM postgrest.auth WHERE id = old.id::text;
      return old;
    END;
    $$ LANGUAGE plpgsql;

    CREATE TRIGGER create_api_user AFTER INSERT
    ON public.users
    FOR EACH ROW
    EXECUTE PROCEDURE postgrest.create_api_user();

    CREATE TRIGGER update_api_user AFTER UPDATE OF id, admin, authentication_token 
    ON public.users
    FOR EACH ROW
    EXECUTE PROCEDURE postgrest.update_api_user();

    CREATE TRIGGER delete_api_user AFTER DELETE
    ON public.users
    FOR EACH ROW
    EXECUTE PROCEDURE postgrest.delete_api_user();
    SQL
  end
end
