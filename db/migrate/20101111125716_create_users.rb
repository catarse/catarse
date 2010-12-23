require 'sexy_pg_constraints'
class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.text :provider, :null => false
      t.text :uid, :null => false
      t.text :email
      t.text :name
      t.text :nickname
      t.text :bio
      t.text :image_url
      t.boolean :newsletter, :default => false
      t.boolean :project_updates, :default => false
      t.timestamps
    end
    constrain :users do |t|
      t.provider :not_blank => true
      t.uid :not_blank => true
      t.bio :length_within => 0..140
    end
    constrain :users do |t|
      t[:provider, :uid].all :unique => true
    end
    add_index :users, :uid
    add_index :users, :name
    add_index :users, :email
  end
  def self.down
    drop_table :users
  end
end
