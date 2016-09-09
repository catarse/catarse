class AddColumnSyncAtToRdevents < ActiveRecord::Migration
  def change
    add_column :rdevents, :sync_at, :datetime
  end
end
