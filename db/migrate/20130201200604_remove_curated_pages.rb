class RemoveCuratedPages < ActiveRecord::Migration
  def up
    drop_table :curated_pages
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
