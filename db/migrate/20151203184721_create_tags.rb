class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.text :name, null: false
      t.text :slug

      t.timestamps
    end
    add_index :tags, :name, unique: true
  end
end
