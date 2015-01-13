class AddAuthenticationTokenIntoUsers < ActiveRecord::Migration
  def change
    add_column :users, :authentication_token, :text, null: false, default: { expr: 'md5(random()::text || clock_timestamp()::text)' }
    add_index :users, :authentication_token, unique: true
  end
end
