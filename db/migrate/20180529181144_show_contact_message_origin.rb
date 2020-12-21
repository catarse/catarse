class ShowContactMessageOrigin < ActiveRecord::Migration[4.2]
  def up
    execute <<-SQL
      ALTER TABLE "direct_messages"
      ADD "data" JSON NOT NULL DEFAULT E'{}';

      CREATE OR REPLACE VIEW "1"."direct_messages" AS
      SELECT dm.user_id,
          dm.to_user_id,
          dm.project_id,
          dm.from_email,
          dm.from_name,
          dm.content,
          dm.data
        FROM direct_messages dm
        WHERE is_owner_or_admin(dm.to_user_id);

      grant select on "1".direct_messages to web_user, admin, anonymous;
      grant insert on "1"."direct_messages" to web_user, admin, anonymous;

      CREATE OR REPLACE FUNCTION public.insert_direct_message()
      RETURNS trigger
      LANGUAGE plpgsql
      AS $function$
                    declare
                      direct_message "1".direct_messages;
                    begin
                      insert into public.direct_messages (user_id, to_user_id, project_id, from_email, from_name, content, data)
                      values (current_user_id(), NEW.to_user_id, NEW.project_id, NEW.from_email, NEW.from_name, NEW.content, NEW.data);

                      return new;
                    end;
                  $function$
    SQL
  end

  def down
    execute <<-SQL
      DROP VIEW "1"."direct_messages";
      CREATE OR REPLACE VIEW "1"."direct_messages" AS
      SELECT dm.user_id,
        dm.to_user_id,
        dm.project_id,
        dm.from_email,
        dm.from_name,
        dm.content
        FROM direct_messages dm
      WHERE is_owner_or_admin(dm.to_user_id);

      grant select on "1".direct_messages to web_user, admin, anonymous;
      grant insert on "1"."direct_messages" to web_user, admin, anonymous;

      ALTER TABLE "direct_messages"
      DROP COLUMN "data";

        CREATE OR REPLACE FUNCTION public.insert_direct_message()
        RETURNS trigger
        LANGUAGE plpgsql
      AS $function$
                    declare
                      direct_message "1".direct_messages;
                    begin
                      insert into public.direct_messages (user_id, to_user_id, project_id, from_email, from_name, content)
                      values (current_user_id(), NEW.to_user_id, NEW.project_id, NEW.from_email, NEW.from_name, NEW.content);

                      return new;
                    end;
                  $function$
    SQL
  end
end
