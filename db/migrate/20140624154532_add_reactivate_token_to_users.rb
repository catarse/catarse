class AddReactivateTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :reactivate_token, :text
  end
end
