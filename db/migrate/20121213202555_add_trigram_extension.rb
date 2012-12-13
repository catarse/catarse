class AddTrigramExtension < ActiveRecord::Migration
  def up
    execute 'CREATE extension pg_trgm;'
  end

  def down
   execute 'DROP extension pg_trgm;'
  end
end
