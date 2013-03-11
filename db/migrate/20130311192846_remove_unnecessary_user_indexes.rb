class RemoveUnnecessaryUserIndexes < ActiveRecord::Migration
  def up
    execute "
    DROP INDEX IF EXISTS users_email;
    DROP INDEX IF EXISTS index_users_on_primary_user_id_and_provider;
    DROP INDEX IF EXISTS index_users_on_uid;
    ALTER TABLE users DROP CONSTRAINT IF EXISTS users_provider_not_blank;
    ALTER TABLE users DROP CONSTRAINT IF EXISTS users_uid_not_blank;
    "
  end

  def down
  end
end
