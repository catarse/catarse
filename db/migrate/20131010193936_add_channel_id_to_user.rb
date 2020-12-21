class AddChannelIdToUser < ActiveRecord::Migration[4.2]
  def change
    add_reference :users, :channel, foreign_key: true
  end
end
