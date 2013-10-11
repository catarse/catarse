class UpdateUsersChannelId < ActiveRecord::Migration
  def up
    execute "UPDATE users SET channel_id = (SELECT channel_id FROM channels_trustees ct WHERE ct.user_id = users.id) WHERE id IN (SELECT user_id FROM channels_trustees)"
  end

  def down
  end
end
