class GrantAnonymousToPostgrest < ActiveRecord::Migration[4.2]
  def change
    execute <<-SQL
    GRANT anonymous TO postgrest;
    GRANT USAGE ON SCHEMA "1" TO anonymous;
    SQL
  end
end
