class AddCommonIdToStates < ActiveRecord::Migration[4.2]
  def change
    add_column :states, :common_id, :uuid, unique: true, foreign_key: false
    add_column :countries, :common_id, :uuid, unique: true, foreign_key: false
  end
end
