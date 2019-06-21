class CreateProjectReportExports < ActiveRecord::Migration
  def change
    create_table :project_report_exports do |t|
      t.references :project, index: true, foreign_key: true
      t.string :report_type, null: false
      t.string :report_type_ext, null: false
      t.string :state, null: false, state: 'pending'
      t.string :output_url
      t.jsonb :output_data, null: false, default: {}

      t.timestamps null: false
    end
  end
end
