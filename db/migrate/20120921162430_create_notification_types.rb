class CreateNotificationTypes < ActiveRecord::Migration
  def change
    create_table :notification_types do |t|
      t.text :name, :null => false
      t.timestamps
    end
  end
end
