class UnifyUsers < ActiveRecord::Migration
  def change
    User.select("users.*, (SELECT string_agg(id::text, ',') FROM users u WHERE u.id <> users.id AND u.email = users.email) AS doppelgangers").where("id IN (SELECT min(id) FROM users WHERE trim(email) <> '' GROUP BY email HAVING count(*) > 1)").each do |user|
      puts "Fixing merging #{user.email} (#{user.doppelgangers}) into #{user.id}"
      execute "
      UPDATE contributions SET user_id = #{user.id} WHERE user_id IN (#{user.doppelgangers});
      UPDATE authorizations SET user_id = #{user.id} WHERE user_id IN (#{user.doppelgangers});
      UPDATE channel_posts SET user_id = #{user.id} WHERE user_id IN (#{user.doppelgangers});
      UPDATE channels_subscribers SET user_id = #{user.id} WHERE user_id IN (#{user.doppelgangers});
      UPDATE notifications SET user_id = #{user.id} WHERE user_id IN (#{user.doppelgangers});
      UPDATE projects SET user_id = #{user.id} WHERE user_id IN (#{user.doppelgangers});
      UPDATE unsubscribes SET user_id = #{user.id} WHERE user_id IN (#{user.doppelgangers});
      UPDATE updates SET user_id = #{user.id} WHERE user_id IN (#{user.doppelgangers});
      DELETE FROM users WHERE id IN (#{user.doppelgangers});
      "
    end
    execute "UPDATE users SET email = NULL WHERE trim(email) = ''"
    remove_index :users, :email
    add_index :users, :email, unique: true
  end
end
