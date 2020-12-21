class AddReceivedAtToContributions < ActiveRecord::Migration[4.2]
  def change
    execute "alter table contributions add column reward_received_at timestamp without time zone;"
  end
end
