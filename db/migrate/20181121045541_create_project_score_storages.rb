class CreateProjectScoreStorages < ActiveRecord::Migration[4.2]
  def change
    create_table :project_score_storages, id: false do |t|
      t.references :project, foreign_key: true
      t.float :score
      t.datetime :refreshed_at, null: false
    end

    add_index :project_score_storages, :project_id, unique: true
  end
end
