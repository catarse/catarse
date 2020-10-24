class DropRewardRanges < ActiveRecord::Migration[4.2]
  def change
    drop_table :reward_ranges
  end
end
