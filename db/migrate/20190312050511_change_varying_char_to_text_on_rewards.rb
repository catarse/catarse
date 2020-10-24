class ChangeVaryingCharToTextOnRewards < ActiveRecord::Migration[4.2]
  def change
    execute <<-SQL

    ALTER TABLE rewards
    ALTER COLUMN uploaded_image TYPE text;

    SQL
  end
end
