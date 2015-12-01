class CreateProjectReminders < ActiveRecord::Migration
  def change
    create_table :project_reminders do |t|
      t.integer :user_id, null: false
      t.integer :project_id, null: false

      t.timestamps
    end

    add_index :project_reminders, [:user_id, :project_id], unique: true
  end
end
