class AddUniqueIndexOnMailMarketingUsers < ActiveRecord::Migration
  def change
    add_index :mail_marketing_users, [:user_id, :mail_marketing_list_id], unique: true, name: 'uidx_user_id_marketing_list'
  end
end
