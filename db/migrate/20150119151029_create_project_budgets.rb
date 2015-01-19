class CreateProjectBudgets < ActiveRecord::Migration
  def change
    create_table :project_budgets do |t|
      t.integer :project_id, null: false
      t.text :name, null: false
      t.decimal :value, precision: 2, null: false

      t.timestamps
    end
  end
end
