class CreateBanks < ActiveRecord::Migration
  def change
    create_table :banks do |t|
      t.text :name, null: false
      t.text :code, null: false

      t.timestamps
    end
    add_index :banks, :code, unique: true
  end
end
