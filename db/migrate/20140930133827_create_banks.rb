class CreateBanks < ActiveRecord::Migration[4.2]
  def change
    create_table :banks do |t|
      t.text :name, null: false
      t.text :code, null: false

      t.timestamps
    end
    add_index :banks, :code, unique: true
  end
end
