class CreateFlexibleProjects < ActiveRecord::Migration
  def change
    create_table :flexible_projects do |t|
      t.references :project

      t.timestamps
    end
  end
end
