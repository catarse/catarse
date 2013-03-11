class DropUidAndProviderConstraintOnUsers < ActiveRecord::Migration
  def up
    execute "
    ALTER TABLE users DROP CONSTRAINT users_provider_uid_unique;
    "
  end

  def down
    execute "
    ALTER TABLE users ADD CONSTRAINT users_provider_uid_unique UNIQUE (provider, uid);
    "
  end
end
