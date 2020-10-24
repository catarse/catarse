class AddPublicNameIntoUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :public_name, :text
  end
end
