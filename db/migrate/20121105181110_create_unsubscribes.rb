class CreateUnsubscribes < ActiveRecord::Migration
  def change
    create_table :unsubscribes do |t|
      t.references :user, null: false
      t.references :notification_type, null: false
      t.references :project

      t.timestamps
    end
    add_index :unsubscribes, :user_id
    add_index :unsubscribes, :notification_type_id
    add_index :unsubscribes, :project_id
  end
end
