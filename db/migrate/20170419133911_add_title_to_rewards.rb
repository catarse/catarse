class AddTitleToRewards < ActiveRecord::Migration
  def change
    add_column :rewards, :title, :text
  end
end
