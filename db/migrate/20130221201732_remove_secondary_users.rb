class RemoveSecondaryUsers < ActiveRecord::Migration
  def up
    [
     'email',
     'name',
     'nickname',
     'bio',
     'image_url',
     'newsletter',
     'project_updates',
     'full_name',
     'address_street',
     'address_number',
     'address_complement',
     'address_neighbourhood',
     'address_city',
     'address_state',
     'address_zip_code',
     'phone_number',
     'locale',
     'cpf',
     'twitter',
     'facebook_link',
     'other_link',
     'uploaded_image',
     'moip_login'
    ].each do |field|
      execute "
      UPDATE users SET #{field} = 
        (SELECT #{field} FROM users su WHERE su.primary_user_id = users.id AND #{field} IS NOT NULL LIMIT 1) 
      WHERE 
        #{field} IS NULL AND primary_user_id IS NULL
        AND (SELECT count(*) FROM users su WHERE su.primary_user_id = users.id AND #{field} IS NOT NULL) > 0"
    end
    # Move authorizations
    execute "
    DROP INDEX index_authorizations_on_uid_and_oauth_provider_id;
    INSERT INTO authorizations (oauth_provider_id, user_id, uid, created_at, updated_at)
    SELECT DISTINCT a.oauth_provider_id, su.primary_user_id, a.uid, current_timestamp, current_timestamp
    FROM authorizations a JOIN users su ON a.user_id = su.id
    WHERE su.primary_user_id IS NOT NULL 
      AND NOT EXISTS (
        SELECT true 
        FROM authorizations a2 
        WHERE a2.user_id = su.primary_user_id AND a2.oauth_provider_id = a.oauth_provider_id);
    DELETE FROM authorizations WHERE user_id IN (SELECT id FROM users WHERE primary_user_id IS NOT NULL);
    CREATE UNIQUE INDEX index_authorizations_on_uid_and_oauth_provider_id ON authorizations (uid, oauth_provider_id);
    "
    # Move backs
    execute "
    UPDATE backers SET user_id = (SELECT primary_user_id FROM users WHERE id = backers.user_id)
    WHERE backers.user_id IN (SELECT id FROM users WHERE primary_user_id IS NOT NULL)
    "
    # Move notifications
    execute "
    UPDATE notifications SET user_id = (SELECT primary_user_id FROM users WHERE id = notifications.user_id)
    WHERE notifications.user_id IN (SELECT id FROM users WHERE primary_user_id IS NOT NULL)
    "
    # Move projects
    execute "
    UPDATE projects SET user_id = (SELECT primary_user_id FROM users WHERE id = projects.user_id)
    WHERE projects.user_id IN (SELECT id FROM users WHERE primary_user_id IS NOT NULL)
    "
    # Move unsubscribes
    execute "
    UPDATE unsubscribes SET user_id = (SELECT primary_user_id FROM users WHERE id = unsubscribes.user_id)
    WHERE unsubscribes.user_id IN (SELECT id FROM users WHERE primary_user_id IS NOT NULL)
    "
    # Move updates
    execute "
    UPDATE updates SET user_id = (SELECT primary_user_id FROM users WHERE id = updates.user_id)
    WHERE updates.user_id IN (SELECT id FROM users WHERE primary_user_id IS NOT NULL)
    "
    # Drop old comments table
    execute "DROP TABLE comments;"
    # Remove secondary users
    execute "DELETE FROM users WHERE primary_user_id IS NOT NULL"
  end

  def down
  end
end
