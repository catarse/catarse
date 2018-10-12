class AddCommonIdToDirectMessages < ActiveRecord::Migration
  def change
    add_column :direct_messages, :common_id, :uuid, unique: true, foreign_key: false
  end
end
