class UnsubscribesView < ActiveRecord::Migration[4.2]
  def up
    execute <<-SQL

    CREATE OR REPLACE VIEW "1"."unsubscribes" AS
      SELECT * FROM unsubscribes un;

    grant select on "1".unsubscribes to anonymous, web_user, admin;

    SQL
  end

  def down
    execute <<-SQL

      DROP VIEW "1"."unsubscribes";

    SQL
  end
end
