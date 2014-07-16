class UpdateDeliverAtOnRewards < ActiveRecord::Migration
  def change
    execute "UPDATE rewards SET deliver_at = (SELECT p.expires_at FROM projects p WHERE p.id = rewards.project_id)::date + days_to_delivery;"
  end
end
