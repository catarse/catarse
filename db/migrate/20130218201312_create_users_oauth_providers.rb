class CreateUsersOauthProviders < ActiveRecord::Migration
  def change
    create_table :users_oauth_providers do |t|
      t.integer :oauth_provider_id, null: false
      t.integer :user_id, null: false
      t.text :uid, null: false, index: { with: :oauth_provider_id, unique: true}
      t.timestamps
    end
  end
end
