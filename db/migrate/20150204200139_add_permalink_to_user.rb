class AddPermalinkToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :permalink, :text
    add_index :users, :permalink, unique: true
  end
end
