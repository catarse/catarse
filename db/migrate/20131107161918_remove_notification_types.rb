class RemoveNotificationTypes < ActiveRecord::Migration
  def up
    remove_column :unsubscribes, :notification_type_id
    remove_column :notifications, :notification_type_id
    drop_table :notification_types
  end

  def down
    execute "
CREATE TABLE notification_types (
    id integer NOT NULL,
    name text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);
    "
    add_column :notifications, :notification_type_id, :integer
    add_column :unsubscribes, :notification_type_id, :integer
  end
end
