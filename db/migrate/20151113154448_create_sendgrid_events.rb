class CreateSendgridEvents < ActiveRecord::Migration
  def change
    create_table :sendgrid_events do |t|
      t.integer :notification_id, null: false, foreign_key: false
      t.integer :notification_user, null: false
      t.text  :notification_type, null: false
      t.text :template_name, null: false
      t.text :event, null: false
      t.text :email, null: false
      t.text :useragent

      t.json :sendgrid_data, null: false
      t.timestamps
    end
  end
end
