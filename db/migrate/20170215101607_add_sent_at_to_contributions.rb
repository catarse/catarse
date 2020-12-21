class AddSentAtToContributions < ActiveRecord::Migration[4.2]
  def change
    execute "alter table contributions add column reward_sent_at timestamp without time zone;"
  end
end
