class CreateUpdates < ActiveRecord::Migration
  def self.up
    create_table :updates do |t|
      t.integer :user_id, :null => false
      t.integer :project_id, :null => false
      t.text :title
      t.text :comment, :null => false
      t.text :comment_html, :null => false
      t.timestamps
    end
    add_foreign_key :updates, :users
    add_foreign_key :updates, :projects
  end

  def self.down
    drop_table :updates
  end
end
