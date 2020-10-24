class AddTitleToRewards < ActiveRecord::Migration[4.2]
  def change
    add_column :rewards, :title, :text
  end
end
