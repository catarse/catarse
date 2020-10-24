class CreateUsersOauthProviders < ActiveRecord::Migration[4.2]
  def change
    create_table :users_oauth_providers do |t|
      t.integer :oauth_provider_id, null: false
      t.integer :user_id, null: false
      t.text :uid, null: false
      t.timestamps
    end

    add_index :users_oauth_providers, %i[uid oauth_provider_id], unique: true
  end
end
