class CreateMailMarketingUsers < ActiveRecord::Migration
  def change
    enable_extension 'uuid-ossp'
    create_table :mail_marketing_users do |t|
      t.references :user, index: true, foreign_key: true
      t.references :mail_marketing_list, index: true, foreign_key: true
      t.uuid :unsubcribe_token, null: false, default: 'uuid_generate_v4()'
      t.timestamp :last_sync_at

      t.timestamps null: false
    end
  end
end
