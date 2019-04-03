class ChangeVaryingCharToTextOnRewards < ActiveRecord::Migration
  def change
    execute <<-SQL

    ALTER TABLE rewards
    ALTER COLUMN uploaded_image TYPE text;

    SQL
  end
end
