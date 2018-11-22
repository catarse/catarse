class AddCommonIdToAddresses < ActiveRecord::Migration
  def change
    add_column :addresses, :common_id, :uuid, unique: true, foreign_key: false
  end
end
