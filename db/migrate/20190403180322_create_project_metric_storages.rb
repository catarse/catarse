class CreateProjectMetricStorages < ActiveRecord::Migration
  def change
    create_table :project_metric_storages, id: false do |t|
      t.references :project, index: { unique: true }, foreign_key: true, primary_key: true, null: false
      t.jsonb :data, null: false, default: {}
      t.datetime :refreshed_at, null: false

      t.timestamps null: false
    end
  end
end
