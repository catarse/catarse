class CreateProjectScoreStorages < ActiveRecord::Migration
  def change
    create_table :project_score_storages, id: false do |t|
      t.references :project, index: true, foreign_key: true, unique: true
      t.float :score
      t.datetime :refreshed_at, null: false
    end
  end
end
