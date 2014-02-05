class CreateVersions < ActiveRecord::Migration
  def self.up
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
  end

  def self.down
    remove_index :versions, [:item_type, :item_id]
    drop_table :versions
  end
end
