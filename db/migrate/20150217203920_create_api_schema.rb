class CreateApiSchema < ActiveRecord::Migration
  def up
    execute 'CREATE SCHEMA "1";'
  end

  def down
    execute 'DROP SCHEMA "1" CASCADE;'
  end
end
