class AddMoipLoginToUsers < ActiveRecord::Migration
  def change
    add_column :users, :moip_login, :string
  end
end
