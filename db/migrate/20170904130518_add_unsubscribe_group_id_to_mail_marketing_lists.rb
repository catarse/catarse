class AddUnsubscribeGroupIdToMailMarketingLists < ActiveRecord::Migration[4.2]
  def up
    add_column :mail_marketing_lists, :unsubscribe_group_id, :integer, foreign_key: false
  end

  def down
    remove_column :mail_marketing_lists, :unsubscribe_group_id
  end
end
