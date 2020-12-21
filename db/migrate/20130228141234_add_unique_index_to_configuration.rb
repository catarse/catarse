class AddUniqueIndexToConfiguration < ActiveRecord::Migration[4.2]
  def change
    add_index :configurations, :name, unique: true
  end
end
