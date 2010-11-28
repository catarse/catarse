class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :name, :null => false
      t.string :email, :null => false
      t.string :biography
      t.string :vanity_id
      t.string :twitter_id
      t.string :facebook_id
      t.boolean :newsletter, :default => false
      t.boolean :project_updates, :default => false
      t.string :crypted_password
      t.string :password_salt
      t.string :persistence_token
      t.timestamps
    end
    constrain :users do |t|
      t.name :not_blank => true
      t.email :not_blank => true, :unique => true
    end
    add_index :users, :name
    add_index :users, :email
  end

  def self.down
    drop_table :users
  end
end

