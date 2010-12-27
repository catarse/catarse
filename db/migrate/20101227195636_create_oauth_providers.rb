require 'sexy_pg_constraints'
class CreateOauthProviders < ActiveRecord::Migration
  def self.up
    create_table :oauth_providers do |t|
      t.text :name, :null => false
      t.text :key, :null => false
      t.text :secret, :null => false
      t.timestamps
    end
    constrain :oauth_providers do |t|
      t.name :not_blank => true, :unique => true
      t.key :not_blank => true
      t.secret :not_blank => true
    end
  end

  def self.down
    drop_table :oauth_providers
  end
end
