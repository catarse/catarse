class GrantAnonymousToPostgrest < ActiveRecord::Migration
  def change
    execute <<-SQL
    GRANT anonymous TO postgrest;
    GRANT USAGE ON SCHEMA "1" TO anonymous;
    SQL
  end
end
