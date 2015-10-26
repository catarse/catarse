class CreateProjectTransitions < ActiveRecord::Migration
  def change
    create_table :project_transitions do |t|
      t.string :to_state, null: false
      t.text :metadata, default: "{}"
      t.integer :sort_key, null: false
      t.integer :project_id, null: false
      t.boolean :most_recent, null: false
      t.timestamps null: false
    end

    add_index(:project_transitions,
              [:project_id, :sort_key],
              unique: true,
              name: "index_project_transitions_parent_sort")
    add_index(:project_transitions,
              [:project_id, :most_recent],
              unique: true,
              where: 'most_recent',
              name: "index_project_transitions_parent_most_recent")
  end
end
