class CreateUserTransferNotification < ActiveRecord::Migration
  def change
    create_table :user_transfer_notifications do |t|
      t.integer :user_id, null: false
      t.integer :user_transfer_id, null: false
      t.text :from_email, null: false
      t.text :from_name, null: false
      t.text :template_name, null: false
      t.text :locale, null: false
      t.timestamp :sent_at
      t.timestamp :deliver_at
      t.timestamps
    end
    execute "ALTER TABLE user_transfer_notifications ALTER deliver_at SET DEFAULT current_timestamp"
  end
end
