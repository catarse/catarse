class CreateDirectMessageTrigger < ActiveRecord::Migration
  def change
    execute <<-SQL
      CREATE FUNCTION send_direct_message() RETURNS trigger
          LANGUAGE plpgsql
          AS $$
          BEGIN
              INSERT INTO direct_message_notifications(user_id, direct_message_id, from_email, from_name, template_name, locale, created_at, updated_at  ) 
              VALUES (new.to_user_id, new.id, new.from_email, new.from_name, 'direct_message', 'pt', current_timestamp, current_timestamp );
              RETURN NEW;
          END;
          $$;
      CREATE TRIGGER send_direct_message AFTER INSERT ON direct_messages FOR EACH ROW EXECUTE PROCEDURE send_direct_message();

      CREATE TRIGGER system_notification_dispatcher AFTER INSERT ON public.direct_message_notifications FOR EACH ROW EXECUTE PROCEDURE public.system_notification_dispatcher();
      SQL
  end
end
