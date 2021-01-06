# This migration comes from catarse_scripts (originally 20201118174237)
class CreateScripts < ActiveRecord::Migration[6.1]
  def change
    create_table :scripts, id: :uuid do |t|
      t.references :creator, null: false, foreign_key: { to_table: :users }
      t.references :executor, optional: true, foreign_key: { to_table: :users }
      t.integer :status, null: false
      t.string :title, null: false, limit: 128
      t.string :description, limit: 512
      t.text :code, null: false
      t.string :ticket_url, limit: 512
      t.string :class_name, null: false, limit: 128
      t.string :tags, array: true, default: []

      t.timestamps
    end
  end
end
