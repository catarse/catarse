class CreateProjectReportNotifications < ActiveRecord::Migration
  def change
    create_table :project_report_notifications do |t|
      t.integer :user_id, null: false
      t.integer :project_report_id, null: false
      t.text :from_email, null: false
      t.text :from_name, null: false
      t.text :cc
      t.text :template_name, null: false
      t.text :locale, null: false
      t.timestamp :sent_at
      t.timestamp :deliver_at

      t.timestamps
    end
    add_column :project_report_notifications, :metadata, :jsonb, null: false, default: '{}'
    execute "ALTER TABLE project_report_notifications ALTER deliver_at SET DEFAULT current_timestamp"
  end
end
