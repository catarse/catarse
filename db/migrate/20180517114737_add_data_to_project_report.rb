class AddDataToProjectReport < ActiveRecord::Migration
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
