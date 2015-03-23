class CreateDbheroDataclips < ActiveRecord::Migration
  def change
    create_table :dbhero_dataclips do |t|
      t.text :description, null: false
      t.text :raw_query, null: false
      t.text :token, null: false
      t.text :user
      t.boolean :private, default: false, null: false

      t.timestamps null: false
    end

    add_index :dbhero_dataclips, :token, unique: true
    add_index :dbhero_dataclips, :user
  end
end

