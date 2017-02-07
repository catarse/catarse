class AddPublicNameIntoUsers < ActiveRecord::Migration
  def change
    add_column :users, :public_name, :text
  end
end
