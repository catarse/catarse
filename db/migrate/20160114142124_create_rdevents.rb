class CreateRdevents < ActiveRecord::Migration
  def change
    create_table :rdevents do |t|
      t.integer :user_id
      t.integer :project_id
      t.text :event_name, null: false
      t.json :metadata

      t.timestamps
    end
  end
end
