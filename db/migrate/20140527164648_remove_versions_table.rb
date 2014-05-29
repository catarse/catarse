class RemoveVersionsTable < ActiveRecord::Migration
  def up
    remove_index :versions, [:item_type, :item_id]
    remove_column :rewards, :reindex_versions
    drop_table :versions
  end

  def down
    SchemaPlus.config.foreign_keys.auto_create = false
    SchemaPlus.config.foreign_keys.auto_index = false

    create_table :versions do |t|
      t.string   :item_type, null: false
      t.integer  :item_id,   null: false
      t.string   :event,     null: false
      t.string   :whodunnit
      t.text     :object
      t.datetime :created_at
    end
    add_index :versions, [:item_type, :item_id]

    SchemaPlus.config.foreign_keys.auto_create = true
    SchemaPlus.config.foreign_keys.auto_index = true

    add_column :rewards, :reindex_versions, :datetime
  end
end
