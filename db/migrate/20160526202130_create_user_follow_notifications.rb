class CreateUserFollowNotifications < ActiveRecord::Migration
  def up
    create_table :user_follow_notifications do |t|
      t.integer :user_id, null: false
      t.integer :user_follow_id, foreign_key: { on_delete: :set_null }
      t.text :from_email, null: false
      t.text :from_name, null: false
      t.text :template_name, null: false
      t.text :locale, null: false
      t.text :cc
      t.timestamp :sent_at
      t.timestamp :deliver_at
      t.timestamps
    end

    execute %{
ALTER TABLE public.user_follow_notifications
ADD COLUMN metadata jsonb NOT NULL DEFAULT '{}',
ALTER COLUMN created_at SET DEFAULT now(),
ALTER COLUMN updated_at SET DEFAULT now(),
ALTER COLUMN deliver_at SET DEFAULT now();

CREATE TRIGGER system_notification_dispatcher AFTER INSERT ON public.user_follow_notifications FOR EACH ROW EXECUTE PROCEDURE system_notification_dispatcher();

CREATE UNIQUE INDEX user_follow_notifications_uidx
on public.user_follow_notifications (template_name, user_id, (metadata->>'follow_id'), (metadata->>'project_id'));
    }
  end

  def down
    drop_table :user_follow_notifications
  end
end
