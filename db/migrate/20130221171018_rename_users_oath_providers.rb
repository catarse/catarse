class RenameUsersOathProviders < ActiveRecord::Migration
  def up
    drop_table :users_oauth_providers
    create_table :authorizations do |t|
      t.integer :oauth_provider_id, null: false
      t.integer :user_id, null: false
      t.text :uid, null: false, index: { with: :oauth_provider_id, unique: true}
      t.timestamps
    end
  end

  def down
    drop_table :authorizations
    create_table :users_oauth_providers do |t|
      t.integer :oauth_provider_id, null: false
      t.integer :user_id, null: false
      t.text :uid, null: false, index: { with: :oauth_provider_id, unique: true}
      t.timestamps
    end
  end
end
