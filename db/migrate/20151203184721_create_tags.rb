class CreateTags < ActiveRecord::Migration[4.2]
  def change
    create_table :tags do |t|
      t.text :name, null: false
      t.text :slug

      t.timestamps
    end
    add_index :tags, :slug, unique: true
  end
end
