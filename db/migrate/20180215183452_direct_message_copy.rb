class DirectMessageCopy < ActiveRecord::Migration[4.2]
  def change
    execute <<-SQL
    CREATE OR REPLACE FUNCTION public.send_direct_message()
     RETURNS trigger
     LANGUAGE plpgsql
    AS $function$
              BEGIN
                  INSERT INTO direct_message_notifications(user_id, direct_message_id, from_email, from_name, template_name, locale, created_at, updated_at, cc  )
                  VALUES (new.to_user_id, new.id, new.from_email, new.from_name, 'direct_message', 'pt', current_timestamp, current_timestamp,  new.from_email);

                  INSERT INTO direct_message_notifications(user_id, direct_message_id, from_email, from_name, template_name, locale, created_at, updated_at, cc  )
                  VALUES (new.user_id, new.id, new.from_email, new.from_name, 'direct_message_copy', 'pt', current_timestamp, current_timestamp,  (SELECT email from users where id = new.to_user_id LIMIT 1));
                  RETURN NEW;
              END;
            $function$
    SQL
  end
end
