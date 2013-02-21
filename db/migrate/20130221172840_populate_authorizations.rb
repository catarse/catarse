class PopulateAuthorizations < ActiveRecord::Migration
  def up
    execute <<-SQL
    INSERT INTO authorizations (oauth_provider_id, user_id, uid, created_at, updated_at)
    SELECT (SELECT id FROM oauth_providers op WHERE op.path = users.provider), id, uid, now(), now() FROM users 
    WHERE EXISTS (SELECT true FROM oauth_providers op WHERE op.path = users.provider);
    SQL
  end

  def down
  end
end
