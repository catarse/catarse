class AddRunOutToRewards < ActiveRecord::Migration[4.2]
  def change
    add_column :rewards, :run_out, :boolean, default: false
  end
end
