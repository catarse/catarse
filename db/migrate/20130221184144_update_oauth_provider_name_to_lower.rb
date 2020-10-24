class UpdateOauthProviderNameToLower < ActiveRecord::Migration[4.2]
  def up
    execute "UPDATE oauth_providers SET name = lower(name);"
  end

  def down
  end
end
