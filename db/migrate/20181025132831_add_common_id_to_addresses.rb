class AddCommonIdToAddresses < ActiveRecord::Migration[4.2]
  def change
    add_column :addresses, :common_id, :uuid, unique: true, foreign_key: false
  end
end
