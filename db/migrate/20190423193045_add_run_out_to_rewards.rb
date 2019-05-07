class AddRunOutToRewards < ActiveRecord::Migration
  def change
    add_column :rewards, :run_out, :boolean, default: false
  end
end
