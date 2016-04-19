class CreateDirectMessages < ActiveRecord::Migration
  def change
    create_table :direct_messages do |t|
      t.references :user
      t.references :to_user, references: :users, null: false
      t.references :project
      t.text :from_email, null: false
      t.text :from_name
      t.text :content, null: false

      t.timestamps
    end
  end
end
