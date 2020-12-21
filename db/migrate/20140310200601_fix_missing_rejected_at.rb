class FixMissingRejectedAt < ActiveRecord::Migration[4.2]
  def up
    execute "
    UPDATE projects SET rejected_at = updated_at WHERE rejected_at IS NULL AND state = 'rejected';
    "
  end

  def down
  end
end
