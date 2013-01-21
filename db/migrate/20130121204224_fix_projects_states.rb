class FixProjectsStates < ActiveRecord::Migration
  def up
    execute "
    UPDATE projects SET state = 'waiting_funds' WHERE state IN ('successful', 'online') AND current_timestamp BETWEEN expires_at and expires_at + '4 day'::interval;
    UPDATE projects SET state = 'online' WHERE state = 'successful' AND current_timestamp < expires_at;
    "
  end

  def down
  end
end
