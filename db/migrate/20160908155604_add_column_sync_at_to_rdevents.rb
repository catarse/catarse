class AddColumnSyncAtToRdevents < ActiveRecord::Migration[4.2]
  def change
    add_column :rdevents, :sync_at, :datetime
  end
end
