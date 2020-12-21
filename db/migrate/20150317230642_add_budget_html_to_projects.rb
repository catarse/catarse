class AddBudgetHtmlToProjects < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :budget_html, :text
  end
end
