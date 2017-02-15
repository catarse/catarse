class AddSentAtToContributions < ActiveRecord::Migration
  def change
    execute "alter table contributions add column reward_sent_at timestamp without time zone;"
  end
end
