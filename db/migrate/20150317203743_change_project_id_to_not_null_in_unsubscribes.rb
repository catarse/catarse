class ChangeProjectIdToNotNullInUnsubscribes < ActiveRecord::Migration
  def change
    execute "
    UPDATE users SET subscribed_to_project_posts = false
    WHERE EXISTS (SELECT true FROM unsubscribes u WHERE u.user_id = users.id AND u.project_id IS NULL);
    DELETE FROM unsubscribes WHERE project_id IS NULL;
    "
    change_column_null :unsubscribes, :project_id, false
  end
end
