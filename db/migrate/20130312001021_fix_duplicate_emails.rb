class FixDuplicateEmails < ActiveRecord::Migration
  def up
    execute "
    CREATE TEMP TABLE target AS SELECT min(id) id, email FROM users WHERE trim(email) <> '' GROUP BY email HAVING count(*) > 1;
    CREATE TEMP TABLE source AS SELECT id, email FROM users WHERE email IN (SELECT email FROM target) AND id NOT IN (SELECT id FROM target);
    UPDATE backers SET user_id = (SELECT t.id FROM target t JOIN source s ON s.email = t.email WHERE s.id = backers.user_id)
    WHERE user_id IN (SELECT id FROM source);
    UPDATE authorizations SET user_id = (SELECT t.id FROM target t JOIN source s ON s.email = t.email WHERE s.id = authorizations.user_id)
    WHERE user_id IN (SELECT id FROM source);
    UPDATE notifications SET user_id = (SELECT t.id FROM target t JOIN source s ON s.email = t.email WHERE s.id = notifications.user_id)
    WHERE user_id IN (SELECT id FROM source);
    UPDATE projects SET user_id = (SELECT t.id FROM target t JOIN source s ON s.email = t.email WHERE s.id = projects.user_id)
    WHERE user_id IN (SELECT id FROM source);
    UPDATE unsubscribes SET user_id = (SELECT t.id FROM target t JOIN source s ON s.email = t.email WHERE s.id = unsubscribes.user_id)
    WHERE user_id IN (SELECT id FROM source);
    UPDATE updates SET user_id = (SELECT t.id FROM target t JOIN source s ON s.email = t.email WHERE s.id = updates.user_id)
    WHERE user_id IN (SELECT id FROM source);
    DELETE FROM users WHERE id IN (SELECT id FROM source);
    DROP TABLE source;
    DROP TABLE target;
    "
  end

  def down
  end
end
