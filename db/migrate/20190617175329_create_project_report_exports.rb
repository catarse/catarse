class CreateProjectReportExports < ActiveRecord::Migration[4.2]
  def change
    create_table :project_report_exports do |t|
      t.references :project, index: true, foreign_key: true
      t.string :report_type, null: false
      t.string :report_type_ext, null: false
      t.string :state, null: false, default: 'pending'
      t.string :output
      t.jsonb :output_data, null: false, default: {}

      t.timestamps null: false
    end
  end
end
