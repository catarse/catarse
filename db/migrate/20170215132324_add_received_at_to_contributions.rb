class AddReceivedAtToContributions < ActiveRecord::Migration
  def change
    execute "alter table contributions add column reward_received_at timestamp without time zone;"
  end
end
