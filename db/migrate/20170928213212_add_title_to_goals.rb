class AddTitleToGoals < ActiveRecord::Migration[4.2]
  def change
    add_column :goals, :title, :text
  end
end
