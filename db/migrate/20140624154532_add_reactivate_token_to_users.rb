class AddReactivateTokenToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :reactivate_token, :text
  end
end
