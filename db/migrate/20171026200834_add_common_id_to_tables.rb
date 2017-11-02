class AddCommonIdToTables < ActiveRecord::Migration
  def change
    add_column :users, :common_id, :uuid, unique: true, foreign_key: false
    add_column :rewards, :common_id, :uuid, unique: true, foreign_key: false
    add_column :projects, :common_id, :uuid, unique: true, foreign_key: false
  end
end
