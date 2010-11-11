class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :biography
      t.string :vanity_url
      t.string :twitter_id
      t.string :facebook_id
      t.boolean :newsletter
      t.boolean :project_updates
      t.string :crypted_password
      t.string :password_salt
      t.string :persistence_token
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end

