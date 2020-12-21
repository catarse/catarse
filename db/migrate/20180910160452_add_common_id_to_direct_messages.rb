class AddCommonIdToDirectMessages < ActiveRecord::Migration[4.2]
  def change
    add_column :direct_messages, :common_id, :uuid, unique: true, foreign_key: false
  end
end
