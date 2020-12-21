class AddDataToProjectReport < ActiveRecord::Migration[4.2]
  def up
    execute %Q{
      ALTER TABLE "project_reports"
      ADD "data" JSON NULL DEFAULT '{}';

    }
  end

  def down
    execute %Q{
      ALTER TABLE "project_reports"
      DROP "data";

    }
  end
end
