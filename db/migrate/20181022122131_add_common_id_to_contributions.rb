class AddCommonIdToContributions < ActiveRecord::Migration[4.2]
  def change
    add_column :contributions, :common_id, :uuid, unique: true, foreign_key: false
  end
end
