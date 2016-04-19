class CreateDirectMessagesView < ActiveRecord::Migration
  def change
    execute <<-SQL
      CREATE VIEW "1".direct_messages AS 
        SELECT dm.user_id, dm.to_user_id, dm.project_id, dm.from_email, dm.from_name, dm.content
        from direct_messages dm;

      CREATE OR REPLACE FUNCTION insert_direct_message() RETURNS trigger
          LANGUAGE plpgsql
          AS $$
              declare
                direct_message "1".direct_messages;
              begin
                insert into public.direct_messages (user_id, to_user_id, project_id, from_email, from_name, content) values (current_user_id(), NEW.to_user_id, NEW.project_id, NEW.from_email, NEW.from_name, NEW.content);
                return new;
              end;
            $$;
      create trigger insert_direct_message instead of insert on "1".direct_messages
        for each row execute procedure public.insert_direct_message();
      grant insert, select on "1".direct_messages to anonymous;
      grant insert, select on "1".direct_messages to web_user;
      grant insert, select on "1".direct_messages to admin;
      grant insert, select on public.direct_messages to anonymous;
      grant insert, select on public.direct_messages to web_user;
      grant insert, select on public.direct_messages to admin;

      grant insert, select on public.direct_message_notifications to anonymous;
      grant insert, select on public.direct_message_notifications to web_user;
      grant insert, select on public.direct_message_notifications to admin;

      grant usage on sequence direct_messages_id_seq to anonymous;
      grant usage on sequence direct_messages_id_seq to web_user;
      grant usage on sequence direct_messages_id_seq to admin;
      grant usage on sequence direct_message_notifications_id_seq to anonymous;
      grant usage on sequence direct_message_notifications_id_seq to web_user;
      grant usage on sequence direct_message_notifications_id_seq to admin;
    SQL
  end
end
