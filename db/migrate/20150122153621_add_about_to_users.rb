class AddAboutToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :about, :text
  end
end
