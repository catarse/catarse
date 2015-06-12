class CreateUserRole < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE ROLE web_user NOLOGIN;
    -- This script assumes a role postgrest and a role anonymous already created
    GRANT usage ON SCHEMA "1" TO web_user;
    GRANT select ON ALL TABLES IN SCHEMA "1" TO web_user;
    GRANT web_user TO postgrest;
    SQL
  end

  def down
    execute <<-SQL
    REVOKE usage ON SCHEMA "1" FROM web_user;
    REVOKE select ON ALL TABLES IN SCHEMA "1" FROM web_user;
    REVOKE web_user FROM postgrest;
    DROP ROLE web_user;
    SQL
  end
end
