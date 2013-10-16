class RemoveSessionsTable < ActiveRecord::Migration
  def up
    drop_table :sessions
  end

  def down
    create_table :sessions do |t|
      t.string :session_id, null: false, foreign_key: false
      t.text :data
      t.timestamps
    end

    add_index :sessions, :session_id
    add_index :sessions, :updated_at
  end
end
