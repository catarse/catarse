class RemoveCuratedPages < ActiveRecord::Migration[4.2]
  def up
    drop_table :curated_pages
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
