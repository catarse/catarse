class AddCreatedAtDefault < ActiveRecord::Migration[4.2]
  def change
    execute "ALTER TABLE ONLY direct_messages ALTER COLUMN created_at SET DEFAULT current_timestamp;"
  end
end
