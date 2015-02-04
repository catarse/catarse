class AddBudgetToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :budget, :text
  end
end
