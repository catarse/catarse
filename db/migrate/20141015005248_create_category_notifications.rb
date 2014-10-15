class CreateCategoryNotifications < ActiveRecord::Migration
  def change
    create_table :category_notifications do |t|
      t.integer :user_id, null: false
      t.integer :category_id, null: false
      t.text :from_email, null: false
      t.text :from_name, null: false
      t.text :template_name, null: false
      t.text :locale, null: false
      t.timestamp :sent_at
      t.timestamps
    end
  end
end
