class AddCommonIdToGoals < ActiveRecord::Migration
  def change
    add_column :goals, :common_id, :uuid, unique: true, foreign_key: false
  end
end
