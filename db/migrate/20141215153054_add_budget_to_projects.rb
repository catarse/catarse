class AddBudgetToProjects < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :budget, :text
  end
end
