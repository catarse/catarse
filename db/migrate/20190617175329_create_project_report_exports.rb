class CreateProjectReportExports < ActiveRecord::Migration
  def change
    create_table :project_report_exports do |t|
      t.references :project, index: true, foreign_key: true
      t.string :report_type
      t.string :state
      t.string :output_url
      t.jsonb :output_data

      t.timestamps null: false
    end
  end
end
