class CreateNotifications < ActiveRecord::Migration
  def up
    create_table :notifications do |t|
      t.integer :user_id
      t.string :user_email
      t.string :template_name
      t.json :metadata, default: '{}'
      t.datetime :sent_at
      t.datetime :deliver_at

      t.timestamps
    end

    execute %Q{
alter table notifications
  alter column metadata set data type jsonb using metadata::jsonb,
  add constraint user_check check ((user_id is null and user_email is not null) or (user_id is not null and user_email is null) or (user_id is not null and user_email is not null));
    }
  end

  def down
    drop_table :notifications
  end
end
