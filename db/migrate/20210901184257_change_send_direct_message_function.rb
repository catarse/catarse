class ChangeSendDirectMessageFunction < ActiveRecord::Migration[6.1]
  def change
    execute <<-SQL
    CREATE OR REPLACE FUNCTION public.send_direct_message()
     RETURNS trigger
     LANGUAGE plpgsql
    AS $function$
            BEGIN
                INSERT INTO direct_message_notifications(user_id, direct_message_id, from_email, from_name, template_name, locale, created_at, updated_at  )
                VALUES (new.to_user_id, new.id, new.from_email, new.from_name, 'direct_message', 'pt', current_timestamp, current_timestamp);

                INSERT INTO direct_message_notifications(user_id, direct_message_id, from_email, from_name, template_name, locale, created_at, updated_at  )
                VALUES (new.user_id, new.id, (SELECT value from settings where name = 'email_no_reply' LIMIT 1), (SELECT value from settings where name = 'company_name' LIMIT 1), 'direct_message_copy', 'pt', current_timestamp, current_timestamp );
                RETURN NEW;
            END;
          $function$
    SQL
  end
end
