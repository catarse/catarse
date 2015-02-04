class AddPermalinkToUser < ActiveRecord::Migration
  def change
    add_column :users, :permalink, :text
    add_index :users, :permalink, unique: true
  end
end
