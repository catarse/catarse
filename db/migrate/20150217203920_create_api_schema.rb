class CreateApiSchema < ActiveRecord::Migration[4.2]
  def up
    execute 'CREATE SCHEMA "1";'
  end

  def down
    execute 'DROP SCHEMA "1" CASCADE;'
  end
end
