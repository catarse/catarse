class CreateTaggings < ActiveRecord::Migration
  def change
    create_table :taggings do |t|
      t.references :tag, null: false
      t.references :project, null: false

      t.timestamps
    end
    add_index :taggings, [:tag_id, :project_id], unique: true
  end
end
