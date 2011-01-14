require 'sexy_pg_constraints'
class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.text :name, :null => false
      t.references :user, :null => false
      t.references :category, :null => false
      t.decimal :goal, :null => false
      t.datetime :expires_at, :null => false
      t.text :about, :null => false
      t.text :headline, :null => false
      t.text :video_url, :null => false
      t.boolean :visible, :default => false
      t.boolean :recommended, :default => false
      t.timestamps
    end
    constrain :projects do |t|
      t.user_id :reference => {:users => :id}
      t.category_id :reference => {:categories => :id}
      t.video_url :not_blank => true
      t.about :not_blank => true
      t.headline :not_blank => true, :length_within => 1..140
    end
    add_index :projects, :user_id
    add_index :projects, :category_id
    add_index :projects, :name
  end
  def self.down
    drop_table :projects
  end
end
