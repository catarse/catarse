class RenameUsersOathProviders < ActiveRecord::Migration[4.2]
  def up
    drop_table :users_oauth_providers
    create_table :authorizations do |t|
      t.integer :oauth_provider_id, null: false
      t.integer :user_id, null: false
      t.text :uid, null: false
      t.timestamps
    end

    add_index :authorizations, %i[uid oauth_provider_id], unique: true
  end

  def down
    drop_table :authorizations
    create_table :users_oauth_providers do |t|
      t.integer :oauth_provider_id, null: false
      t.integer :user_id, null: false
      t.text :uid, null: false
      t.timestamps
    end

    add_index :users_oauth_providers, %i[uid oauth_provider_id], unique: true
  end
end
