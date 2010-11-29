require 'sexy_pg_constraints'

class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :provider, :null => false
      t.string :uid, :null => false
      t.string :email
      t.string :name
      t.string :nickname
      t.string :biography
      t.string :image_url
      t.boolean :newsletter, :default => false
      t.boolean :project_updates, :default => false
      t.timestamps
    end
    constrain :users do |t|
      t.provider :not_blank => true
      t.uid :not_blank => true
    end
    constrain :users do |t|
      t[:provider, :uid].all :unique => true
    end
    add_index :users, :provider
    add_index :users, :uid
    add_index :users, [:provider, :uid], :unique => true
    add_index :users, :name
    add_index :users, :email
  end

  def self.down
    drop_table :users
  end
end
