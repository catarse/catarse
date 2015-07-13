class CreateAdminRole < ActiveRecord::Migration
  def up
    execute <<-SQL
    DO
      $body$
    BEGIN
      IF NOT EXISTS (SELECT * FROM pg_catalog.pg_roles WHERE rolname = 'postgrest') THEN
        CREATE ROLE postgrest NOLOGIN;
      END IF;
    END
    $body$;

    DO
      $body$
    BEGIN
      IF NOT EXISTS (SELECT * FROM pg_catalog.pg_roles WHERE rolname = 'admin') THEN
        CREATE ROLE admin NOLOGIN;
      END IF;
    END
    $body$;
    -- This script assumes a role postgrest and a role anonymous already created
    GRANT usage ON SCHEMA postgrest TO admin;
    GRANT usage ON SCHEMA "1" TO admin;
    GRANT select, insert ON postgrest.auth TO admin;
    GRANT select ON ALL TABLES IN SCHEMA "1" TO admin;
    GRANT admin TO postgrest;
    SQL
  end

  def down
    execute <<-SQL
    REVOKE usage ON SCHEMA postgrest FROM admin;
    REVOKE usage ON SCHEMA "1" FROM admin;
    REVOKE select, insert ON postgrest.auth FROM admin;
    REVOKE select ON ALL TABLES IN SCHEMA "1" FROM admin;
    REVOKE admin FROM postgrest;
    DROP ROLE admin;
    SQL
  end
end
