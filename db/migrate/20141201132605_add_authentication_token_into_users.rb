class AddAuthenticationTokenIntoUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :authentication_token, :text, null: false, default: ->{ 'md5(random()::text || clock_timestamp()::text)' }
    add_index :users, :authentication_token, unique: true
  end
end
