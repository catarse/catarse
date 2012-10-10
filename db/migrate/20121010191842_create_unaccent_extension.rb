class CreateUnaccentExtension < ActiveRecord::Migration
  def up
    execute "CREATE EXTENSION unaccent"
  end

  def down
    execute "DROP EXTENSION unaccent"
  end
end
