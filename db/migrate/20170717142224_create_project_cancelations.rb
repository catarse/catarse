class CreateProjectCancelations < ActiveRecord::Migration
  def change
    create_table :project_cancelations do |t|
      t.references :project, null: false, foreign_key: true, index: { unique: true}

      t.timestamps null: false
    end
  end
end
