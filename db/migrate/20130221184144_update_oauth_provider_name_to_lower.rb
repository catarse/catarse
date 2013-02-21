class UpdateOauthProviderNameToLower < ActiveRecord::Migration
  def up
    execute "UPDATE oauth_providers SET name = lower(name);"
  end

  def down
  end
end
