class CreateUserLinks < ActiveRecord::Migration
  def change
    create_table :user_links do |t|
      t.text :link, null: false
      t.integer :user_id, null: false

      t.timestamps
    end
  end
end
