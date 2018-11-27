class AddCommonIdToStates < ActiveRecord::Migration
  def change
    add_column :states, :common_id, :uuid, unique: true, foreign_key: false
    add_column :countries, :common_id, :uuid, unique: true, foreign_key: false
  end
end
