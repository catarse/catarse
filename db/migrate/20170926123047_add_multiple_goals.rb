class AddMultipleGoals < ActiveRecord::Migration
  def change
    create_table :goals do |t|
      t.references :project, null: false
      t.text :description
      t.decimal :value

      t.timestamps
    end
  end
end
