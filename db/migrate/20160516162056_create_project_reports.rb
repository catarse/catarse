class CreateProjectReports < ActiveRecord::Migration
  def change
    create_table :project_reports do |t|
      t.references :project, null: false
      t.references :user
      t.text :reason, null: false
      t.text :email
      t.text :details

      t.timestamps
    end
  end
end
