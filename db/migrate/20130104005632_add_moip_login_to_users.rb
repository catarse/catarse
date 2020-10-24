class AddMoipLoginToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :moip_login, :string
  end
end
