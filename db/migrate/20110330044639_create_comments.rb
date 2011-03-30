require 'sexy_pg_constraints'
class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.text :title
      t.text :comment, :null => false
      t.text :comment_html
      t.references :commentable, :polymorphic => true, :null => false
      t.references :user, :null => false
      t.boolean :project_update, :default => false
      t.timestamps
    end
    constrain :comments do |t|
      t.user_id :reference => {:users => :id}
      t.comment :not_blank => true
    end
    add_index :comments, :commentable_type
    add_index :comments, :commentable_id
    add_index :comments, :user_id
  end

  def self.down
    drop_table :comments
  end
end
