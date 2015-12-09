class CreateProjectErrors < ActiveRecord::Migration
  def change
    create_table :project_errors do |t|
      t.references :project, null: false
      t.text :error
      t.text :to_state, null: false

      t.timestamps
    end
  end
end
