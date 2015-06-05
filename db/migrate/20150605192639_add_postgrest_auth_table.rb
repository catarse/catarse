class AddPostgrestAuthTable < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE SCHEMA postgrest;
      SET search_path = postgrest, pg_catalog, public;

      CREATE TABLE postgrest.auth (
        id character varying NOT NULL,
        rolname name NOT NULL,
        pass character(60) NOT NULL,
        CONSTRAINT auth_pkey PRIMARY KEY (id)
      ) WITH ( OIDS=FALSE );

      CREATE FUNCTION check_role_exists() RETURNS trigger
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
    SQL
  end

  def down
    execute "DROP SCHEMA postgrest CASCADE;"
  end
end
