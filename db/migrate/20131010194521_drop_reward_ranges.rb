class DropRewardRanges < ActiveRecord::Migration
  def change
    drop_table :reward_ranges
  end
end
