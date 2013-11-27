class MakeAuthorizationsUniqueOnUserAndOauthProvider < ActiveRecord::Migration
  def up
    execute "DELETE FROM authorizations WHERE user_id IN (SELECT user_id FROM authorizations GROUP BY user_id HAVING count(*) > 1)"
    add_index :authorizations, [:oauth_provider_id, :user_id], unique: true
  end

  def down
    remove_index :authorizations, [:oauth_provider_id, :user_id], unique: true
  end
end
