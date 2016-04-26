class AddCcToNotifications < ActiveRecord::Migration
  def change
    add_column :contribution_notifications, :cc, :text
    add_column :project_notifications, :cc, :text
    add_column :user_notifications, :cc, :text
    add_column :category_notifications, :cc, :text
    add_column :project_post_notifications, :cc, :text
    add_column :user_transfer_notifications, :cc, :text
    add_column :donation_notifications, :cc, :text
    add_column :direct_message_notifications, :cc, :text
     execute <<-SQL
      CREATE OR REPLACE FUNCTION send_direct_message() RETURNS trigger
          LANGUAGE plpgsql
          AS $$
          BEGIN
              INSERT INTO direct_message_notifications(user_id, direct_message_id, from_email, from_name, template_name, locale, created_at, updated_at, cc  ) 
              VALUES (new.to_user_id, new.id, new.from_email, new.from_name, 'direct_message', 'pt', current_timestamp, current_timestamp,  new.from_email);
              RETURN NEW;
          END;
          $$;
      SQL
  end
end
