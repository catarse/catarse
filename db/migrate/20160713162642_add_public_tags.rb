class AddPublicTags < ActiveRecord::Migration
  def up
    create_table :public_tags do |t|
      t.text :name, null: false
      t.text :slug

      t.timestamps
    end
    add_index :public_tags, :slug, unique: true
    add_column :taggings, :public_tag_id, :integer
    change_column_null :taggings, :tag_id, true

    add_index :taggings, [:public_tag_id, :project_id], unique: true
  end

  def down
    remove_column :taggings, :public_tag_id
    drop_table :public_tags
    change_column_null :taggings, :tag_id, false
  end
end
