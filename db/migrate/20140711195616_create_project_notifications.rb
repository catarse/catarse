class CreateProjectNotifications < ActiveRecord::Migration
  def change
    create_table :project_notifications do |t|
      t.integer :user_id, null: false
      t.integer :project_id, null: false
      t.text :from_email, null: false
      t.text :from_name, null: false
      t.text :template_name, null: false
      t.text :locale, null: false
      t.timestamp :sent_at
    end
  end
end
